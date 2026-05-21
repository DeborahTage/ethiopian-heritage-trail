import { useEffect, useMemo, useState } from 'react';
import type { ReactNode } from 'react';
import { Link, useParams } from 'react-router-dom';
import { ArrowLeft, BadgeCheck, BookOpen, Clock, Eye, Image, Mic, Plus, Save, Trash2, Upload, Video } from 'lucide-react';
import { fetchLandmark } from './api/landmarkApi';
import { fetchLandmarkContent, updateLandmarkContent, uploadLandmarkFile } from './api/contentApi';
import type { BadgeRarity, LandmarkContentPayload } from './contentTypes';
import { emptyContent } from './contentTypes';

type Tab = 'story' | 'media' | 'badge' | 'practical';

const cloneContent = (): LandmarkContentPayload => JSON.parse(JSON.stringify(emptyContent));

export const ContentEditorPage = () => {
    const { id = '' } = useParams();
    const [tab, setTab] = useState<Tab>('story');
    const [preview, setPreview] = useState(false);
    const [content, setContent] = useState<LandmarkContentPayload>(cloneContent);
    const [landmarkName, setLandmarkName] = useState('Landmark');
    const [status, setStatus] = useState('Draft');
    const [loaded, setLoaded] = useState(false);

    useEffect(() => {
        if (!id) return;
        Promise.allSettled([fetchLandmark(id), fetchLandmarkContent(id)]).then(([landmark, existing]) => {
            if (landmark.status === 'fulfilled') setLandmarkName(landmark.value.name);
            if (existing.status === 'fulfilled') {
                setContent({
                    story: existing.value.story ?? cloneContent().story,
                    media: existing.value.media ?? cloneContent().media,
                    badge: existing.value.badge ?? cloneContent().badge,
                    practicalInfo: existing.value.practicalInfo ?? cloneContent().practicalInfo,
                });
                setStatus('Loaded');
            }
            setLoaded(true);
        });
    }, [id]);

    useEffect(() => {
        if (!loaded || !id) return;
        setStatus('Unsaved changes');
        const handle = window.setTimeout(() => {
            updateLandmarkContent(id, content)
                .then(() => setStatus('Auto-saved'))
                .catch(() => setStatus('Auto-save failed'));
        }, 5000);
        return () => window.clearTimeout(handle);
    }, [content, id, loaded]);

    const setStory = (key: keyof LandmarkContentPayload['story'], value: string | string[]) => {
        setContent((current) => ({ ...current, story: { ...current.story, [key]: value } }));
    };

    const setMedia = (key: keyof LandmarkContentPayload['media'], value: string | string[] | number) => {
        setContent((current) => ({ ...current, media: { ...current.media, [key]: value } }));
    };

    const setBadge = (key: keyof LandmarkContentPayload['badge'], value: string | number) => {
        setContent((current) => ({ ...current, badge: { ...current.badge, [key]: value } }));
    };

    const setPractical = (key: keyof LandmarkContentPayload['practicalInfo'], value: string) => {
        setContent((current) => ({ ...current, practicalInfo: { ...current.practicalInfo, [key]: value } }));
    };

    const upload = async (kind: 'image' | 'video' | 'audio', file: File) => {
        setStatus('Uploading...');
        const uploaded = await uploadLandmarkFile(kind, file, id);
        setStatus('Upload complete');
        return uploaded.url;
    };

    const publish = async () => {
        try {
            setStatus('Publishing...');
            await updateLandmarkContent(id, content);
            setStatus('Published');
        } catch {
            setStatus('Publish failed');
        }
    };

    const tabs = useMemo(() => [
        ['story', BookOpen, 'Story'],
        ['media', Image, 'Media'],
        ['badge', BadgeCheck, 'Badge'],
        ['practical', Clock, 'Practical Info'],
    ] as const, []);

    if (preview) {
        return <TouristPreview name={landmarkName} content={content} onClose={() => setPreview(false)} />;
    }

    return (
        <div className="space-y-6">
            <div className="flex flex-wrap items-center justify-between gap-3">
                <div>
                    <Link to="/landmarks" className="inline-flex items-center gap-2 text-sm text-textSecondary hover:text-white">
                        <ArrowLeft className="w-4 h-4" /> Back
                    </Link>
                    <h1 className="mt-2 text-3xl font-bold text-white tracking-tight">{landmarkName} Content</h1>
                    <p className="text-sm text-textSecondary">{status}</p>
                </div>
                <div className="flex gap-2">
                    <button onClick={() => setPreview(true)} className="inline-flex items-center gap-2 rounded-lg border border-gray-700 px-4 py-2 text-white hover:bg-white/5">
                        <Eye className="w-4 h-4" /> Preview as Tourist
                    </button>
                    <button onClick={publish} className="inline-flex items-center gap-2 rounded-lg bg-primary px-4 py-2 font-medium text-secondary hover:bg-primary/90">
                        <Save className="w-4 h-4" /> Publish
                    </button>
                </div>
            </div>

            <div className="flex flex-wrap gap-2 border-b border-gray-800">
                {tabs.map(([key, Icon, label]) => (
                    <button
                        key={key}
                        onClick={() => setTab(key)}
                        className={`inline-flex items-center gap-2 px-4 py-3 text-sm font-medium ${tab === key ? 'border-b-2 border-primary text-primary' : 'text-textSecondary hover:text-white'}`}
                    >
                        <Icon className="h-4 w-4" /> {label}
                    </button>
                ))}
            </div>

            {tab === 'story' && (
                <section className="grid gap-5 lg:grid-cols-2">
                    <Field label="Short story English" value={content.story.shortStoryEn ?? ''} onChange={(value) => setStory('shortStoryEn', value)} textarea />
                    <Field label="Short story Amharic" value={content.story.shortStoryAm ?? ''} onChange={(value) => setStory('shortStoryAm', value)} textarea amharic />
                    <Field label="Full history English" value={content.story.fullHistoryEn ?? ''} onChange={(value) => setStory('fullHistoryEn', value)} textarea tall />
                    <Field label="Full history Amharic" value={content.story.fullHistoryAm ?? ''} onChange={(value) => setStory('fullHistoryAm', value)} textarea tall amharic />
                    <div className="lg:col-span-2 space-y-3">
                        <Label text="Fun facts" />
                        {content.story.funFacts.map((fact, index) => (
                            <div key={index} className="flex gap-2">
                                <input value={fact} onChange={(event) => {
                                    const next = [...content.story.funFacts];
                                    next[index] = event.target.value;
                                    setStory('funFacts', next);
                                }} className="w-full rounded-lg border border-gray-800 bg-surface px-3 py-2 text-white" />
                                <button onClick={() => setStory('funFacts', content.story.funFacts.filter((_, i) => i !== index))} className="rounded-lg bg-gray-800 p-2 text-textSecondary hover:text-error">
                                    <Trash2 className="h-4 w-4" />
                                </button>
                            </div>
                        ))}
                        <button onClick={() => setStory('funFacts', [...content.story.funFacts, ''])} className="inline-flex items-center gap-2 rounded-lg border border-gray-700 px-3 py-2 text-white hover:bg-white/5">
                            <Plus className="h-4 w-4" /> Add fact
                        </button>
                    </div>
                </section>
            )}

            {tab === 'media' && (
                <section className="grid gap-5 lg:grid-cols-2">
                    <UploadField label="Hero image" accept="image/*" previewUrl={content.media.heroImageUrl} onFile={async (file) => setMedia('heroImageUrl', await upload('image', file))} />
                    <UploadField label="Video thumbnail" accept="image/*" previewUrl={content.media.videoThumbnailUrl} onFile={async (file) => setMedia('videoThumbnailUrl', await upload('image', file))} />
                    <UploadField label="Video" accept="video/mp4" icon={<Video className="h-5 w-5" />} onFile={async (file) => {
                        const url = await upload('video', file);
                        setMedia('videoUrl', url);
                        const element = document.createElement('video');
                        element.preload = 'metadata';
                        element.onloadedmetadata = () => setMedia('videoDuration', Math.round(element.duration));
                        element.src = URL.createObjectURL(file);
                    }} />
                    <UploadField label="Audio guide" accept="audio/mpeg,audio/mp3" icon={<Mic className="h-5 w-5" />} onFile={async (file) => setMedia('audioGuideUrl', await upload('audio', file))} />
                    <Field label="Video duration seconds" value={String(content.media.videoDuration ?? 0)} onChange={(value) => setMedia('videoDuration', Number(value))} type="number" />
                    <Field label="Audio duration seconds" value={String(content.media.audioDuration ?? 0)} onChange={(value) => setMedia('audioDuration', Number(value))} type="number" />
                    <div className="lg:col-span-2 space-y-3">
                        <Label text="Gallery" />
                        <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
                            {content.media.galleryUrls.map((url, index) => (
                                <div key={url} className="relative aspect-video overflow-hidden rounded-lg border border-gray-800">
                                    <img src={url} className="h-full w-full object-cover" />
                                    <button onClick={() => setMedia('galleryUrls', content.media.galleryUrls.filter((_, i) => i !== index))} className="absolute right-2 top-2 rounded bg-black/70 p-1 text-white">
                                        <Trash2 className="h-4 w-4" />
                                    </button>
                                </div>
                            ))}
                            <UploadTile onFile={async (file) => setMedia('galleryUrls', [...content.media.galleryUrls, await upload('image', file)])} />
                        </div>
                    </div>
                </section>
            )}

            {tab === 'badge' && (
                <section className="grid gap-5 lg:grid-cols-2">
                    <Field label="Badge name" value={content.badge.badgeName ?? ''} onChange={(value) => setBadge('badgeName', value)} />
                    <Field label="Points" value={String(content.badge.badgePoints)} onChange={(value) => setBadge('badgePoints', Math.max(0, Number(value)))} type="number" />
                    <div>
                        <Label text="Rarity" />
                        <select value={content.badge.badgeRarity} onChange={(event) => setBadge('badgeRarity', event.target.value as BadgeRarity)} className="mt-2 w-full rounded-lg border border-gray-800 bg-surface px-3 py-2 text-white">
                            {['common', 'rare', 'epic', 'legendary'].map((rarity) => <option key={rarity}>{rarity}</option>)}
                        </select>
                    </div>
                    <UploadField label="Badge icon" accept="image/*" previewUrl={content.badge.badgeIconUrl} onFile={async (file) => setBadge('badgeIconUrl', await upload('image', file))} />
                </section>
            )}

            {tab === 'practical' && (
                <section className="grid gap-5 lg:grid-cols-2">
                    <Field label="Opening hours" value={content.practicalInfo.openingHours ?? ''} onChange={(value) => setPractical('openingHours', value)} />
                    <Field label="Entry fee" value={content.practicalInfo.entryFee ?? ''} onChange={(value) => setPractical('entryFee', value)} />
                    <Field label="Best time" value={content.practicalInfo.bestTime ?? ''} onChange={(value) => setPractical('bestTime', value)} />
                    <Field label="Contact phone" value={content.practicalInfo.contactPhone ?? ''} onChange={(value) => setPractical('contactPhone', value)} />
                </section>
            )}
        </div>
    );
};

const Label = ({ text }: { text: string }) => <label className="text-sm font-medium text-textSecondary">{text}</label>;

const Field = ({ label, value, onChange, textarea, tall, type = 'text', amharic }: {
    label: string;
    value: string;
    onChange: (value: string) => void;
    textarea?: boolean;
    tall?: boolean;
    type?: string;
    amharic?: boolean;
}) => (
    <div>
        <Label text={label} />
        {textarea ? (
            <textarea value={value} onChange={(event) => onChange(event.target.value)} rows={tall ? 8 : 4} className={`mt-2 w-full rounded-lg border border-gray-800 bg-surface px-3 py-2 text-white ${amharic ? 'font-ethiopic' : ''}`} />
        ) : (
            <input type={type} min={type === 'number' ? 0 : undefined} value={value} onChange={(event) => onChange(event.target.value)} className="mt-2 w-full rounded-lg border border-gray-800 bg-surface px-3 py-2 text-white" />
        )}
    </div>
);

const UploadField = ({ label, accept, previewUrl, onFile, icon }: {
    label: string;
    accept: string;
    previewUrl?: string;
    onFile: (file: File) => void;
    icon?: ReactNode;
}) => (
    <div className="space-y-2">
        <Label text={label} />
        {previewUrl && <img src={previewUrl} className="h-36 w-full rounded-lg border border-gray-800 object-cover" />}
        <label className="flex cursor-pointer items-center justify-center gap-2 rounded-lg border border-dashed border-gray-700 bg-surface px-4 py-8 text-textSecondary hover:text-white">
            {icon ?? <Upload className="h-5 w-5" />} Upload
            <input type="file" accept={accept} className="hidden" onChange={(event) => event.target.files?.[0] && onFile(event.target.files[0])} />
        </label>
    </div>
);

const UploadTile = ({ onFile }: { onFile: (file: File) => void }) => (
    <label className="flex aspect-video cursor-pointer items-center justify-center rounded-lg border border-dashed border-gray-700 text-textSecondary hover:text-white">
        <Plus className="h-6 w-6" />
        <input type="file" accept="image/*" className="hidden" onChange={(event) => event.target.files?.[0] && onFile(event.target.files[0])} />
    </label>
);

const TouristPreview = ({ name, content, onClose }: { name: string; content: LandmarkContentPayload; onClose: () => void }) => (
    <div className="mx-auto max-w-sm overflow-hidden rounded-3xl border border-gray-800 bg-[#111827] text-white shadow-2xl">
        <div className="flex items-center justify-between px-4 py-3">
            <h2 className="truncate text-lg font-semibold">{name}</h2>
            <button onClick={onClose} className="rounded-lg bg-white/10 px-3 py-1 text-sm">Close</button>
        </div>
        {content.media.heroImageUrl && <img src={content.media.heroImageUrl} className="h-52 w-full object-cover" />}
        <div className="space-y-4 p-4">
            <div className="rounded-xl bg-primary/15 p-3">
                <div className="font-semibold">{content.badge.badgeName || 'Heritage Badge'}</div>
                <div className="text-sm text-primary">+{content.badge.badgePoints} points · {content.badge.badgeRarity}</div>
            </div>
            <p className="text-sm leading-6">{content.story.shortStoryEn || content.story.shortStoryAm || 'No story published yet.'}</p>
            <div className="grid grid-cols-2 gap-2">
                {content.media.galleryUrls.slice(0, 4).map((url) => <img key={url} src={url} className="aspect-square rounded-lg object-cover" />)}
            </div>
            <ul className="space-y-2 text-sm text-textSecondary">
                {content.story.funFacts.map((fact) => <li key={fact}>★ {fact}</li>)}
            </ul>
        </div>
    </div>
);
