import { Outlet, NavLink } from 'react-router-dom';

export const AnalyticsLayout = () => {
    return (
        <div className="space-y-6 max-w-7xl mx-auto w-full">
            <div>
                <h1 className="text-3xl font-bold text-white tracking-tight">Analytics Dashboard</h1>
                <p className="text-textSecondary mt-1">Visualize global scan behaviors, user flows, and site performance.</p>
            </div>

            <div className="flex space-x-2 border-b border-gray-800 pb-px">
                {[
                    { to: '.', label: 'Overview', exact: true },
                    { to: 'heatmap', label: 'Heatmap' },
                    { to: 'flow', label: 'Flow Analysis' },
                    { to: 'reports', label: 'Reports' }
                ].map(tab => (
                    <NavLink
                        key={tab.to}
                        to={tab.to}
                        end={tab.exact}
                        className={({ isActive }) =>
                            `px-4 py-2 border-b-2 font-medium text-sm transition ${isActive
                                ? 'border-primary text-primary'
                                : 'border-transparent text-textSecondary hover:text-white hover:border-gray-500'
                            }`
                        }
                    >
                        {tab.label}
                    </NavLink>
                ))}
            </div>

            <div className="pt-2">
                <Outlet />
            </div>
        </div>
    );
};
