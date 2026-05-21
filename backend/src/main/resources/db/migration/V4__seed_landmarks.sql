-- V4__seed_landmarks.sql
-- 5 real Ethiopian heritage landmarks

INSERT INTO landmarks (id, name, name_am, description, description_am, location, address, region, category, qr_secret, gps_radius_meters, points_value)
VALUES
(
    uuid_generate_v4(),
    'Lalibela Rock-Hewn Churches',
    'ላሊበላ ዋሻ አብያተ ክርስቲያናት',
    'UNESCO World Heritage Site featuring 11 medieval monolithic churches carved from red volcanic rock in the 12th–13th century.',
    'ከቀይ እሳተ ገሞራ ዓለት የተቀረጹ 11 መካከለኛ ዘመን ቤተ ክርስቲያናት ያሉበት የዩኔስኮ የዓለም ቅርስ ቦታ።',
    ST_SetSRID(ST_MakePoint(39.0447, 12.0317), 4326),
    'Lalibela, Amhara Region',
    'Amhara',
    'CHURCH',
    'lalibela-qr-secret-2024',
    300,
    50
),
(
    uuid_generate_v4(),
    'Aksum Obelisks',
    'አክሱም ሐውልቶች',
    'Ancient stelae of the Aksumite Empire, dating back over 1,700 years. The tallest standing obelisk is 24 meters high.',
    'ከ1,700 ዓመት በላይ ዕድሜ ያላቸው የጥንቱ የአክሱም ግዛት ሐውልቶች።',
    ST_SetSRID(ST_MakePoint(38.7183, 14.1297), 4326),
    'Aksum, Tigray Region',
    'Tigray',
    'HERITAGE',
    'aksum-obelisks-secret-2024',
    250,
    40
),
(
    uuid_generate_v4(),
    'Fasil Ghebbi (Royal Enclosure)',
    'ፋሲል ግቢ',
    'UNESCO World Heritage fortress-city of Emperor Fasilides in Gondar, featuring castles, churches and decorative elements.',
    'የዩኔስኮ የዓለም ቅርስ የሆነ፣ የንጉሠ ነገሥት ፋሲለደስ ምሽግ ከተማ።',
    ST_SetSRID(ST_MakePoint(37.4673, 12.6030), 4326),
    'Gondar, Amhara Region',
    'Amhara',
    'PALACE',
    'fasil-ghebbi-secret-2024',
    200,
    40
),
(
    uuid_generate_v4(),
    'Simien Mountains National Park',
    'ሰሜን ተራሮች ብሔራዊ ፓርክ',
    'UNESCO World Heritage site with dramatic landscapes, endemic species including the Gelada baboon and Ethiopian wolf.',
    'ጌላዳ ዝንጀሮ እና የኢትዮጵያ ተኩላን ጨምሮ ጥሩ የዓለም ቅርስ።',
    ST_SetSRID(ST_MakePoint(38.0667, 13.2333), 4326),
    'Debark, Amhara Region',
    'Amhara',
    'NATURE',
    'simien-mountains-secret-2024',
    500,
    30
),
(
    uuid_generate_v4(),
    'National Museum of Ethiopia',
    'የኢትዮጵያ ብሔራዊ ሙዚየም',
    'Home to Lucy (Australopithecus afarensis fossil), ancient artifacts and Ethiopian art collections.',
    'የሉሲ (አውስትራሎፒቴከስ አፋሬንሲስ) ቅሪተ አካልና ጥንታዊ የኢትዮጵያ ቅርሶች ቤት።',
    ST_SetSRID(ST_MakePoint(38.7599, 9.0263), 4326),
    'Addis Ababa',
    'Addis Ababa',
    'MUSEUM',
    'national-museum-et-secret-2024',
    150,
    20
);
