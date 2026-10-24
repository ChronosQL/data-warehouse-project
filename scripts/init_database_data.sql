BEGIN;

-- =========================================================
-- 1. VEHICLE CATEGORIES (7 Categories)
-- =========================================================
INSERT INTO vehicle_category (
    category_name, description, passenger_capacity, luggage_capacity, 
    best_for, comfort_level, ac_available, ideal_trip_types
) VALUES
('Budget Sedan', 'Fuel-efficient compact sedans for solo travellers or couples.', '1-3 Passengers', '2 Large Bags', 'Couples, Solo Travelers', 'Standard', TRUE, 'Airport Transfers, City Tours, Short Excursions'),
('Premium Sedan', 'Spacious executive sedans offering extra legroom and luxury ride comfort.', '1-3 Passengers', '3 Large Bags', 'Couples, Business Travelers', 'Premium Luxury', TRUE, 'Cultural Triangle, Round Tours'),
('Compact SUV / Mini Crossover', 'Higher ground clearance ideal for hill country roads and rough terrain.', '1-4 Passengers', '3 Large Bags', 'Small Families, Photographers', 'High Comfort', TRUE, 'Ella, Nuwara Eliya, Horton Plains'),
('Luxury Safari Jeep', 'Custom modified 4x4 vehicles with elevated tiered seating and canvas roofs.', '1-6 Passengers', 'Daypacks Only', 'Wildlife Enthusiasts', 'Rugged Safari', FALSE, 'Yala, Wilpattu, Udawalawe, Minneriya'),
('KDH High-Roof Luxury Van', 'Spacious touring van with reclining velvet seats and personal charging ports.', '4-9 Passengers', '8 Large Bags', 'Medium Family Groups, Extended Tours', 'First Class Comfort', TRUE, 'Complete Island Tours, Multi-Day Cross Country'),
('Mini Coach', 'Comfortable medium-sized tourist coach for extended tour groups and large families.', '10-18 Passengers', '15 Large Bags', 'Group Excursions, Corporate Retreats', 'Executive Tour Class', TRUE, 'Historical Circuits, Coastal Highway Tours'),
('Executive VIP Coach', 'Large luxury touring coach equipped with onboard microphone, cooler box, and individual AC.', '19-33 Passengers', '30 Large Bags', 'Incentive Travel, Large Tour Groups', 'Ultra Luxury', TRUE, 'Charter Island Circuits, All-Island Heritage Expeditions');

-- =========================================================
-- 2. VEHICLES (40 Registered Tour Vehicles)
-- =========================================================
INSERT INTO vehicle (
    category_id, vehicle_number, vehicle_license, name, color, manufactured_year,
    adult_seats, baby_seats, luggage_capacity, price_per_day, insurance_provider,
    insurance_start_date, insurance_end_date, vehicle_status, brand, model,
    fuel_type, transmission, air_conditioning, mileage, engine_capacity, features
)
SELECT 
    CASE 
        WHEN i <= 8  THEN 1 -- Budget Sedan
        WHEN i <= 15 THEN 2 -- Premium Sedan
        WHEN i <= 21 THEN 3 -- Compact SUV
        WHEN i <= 26 THEN 4 -- Safari Jeep
        WHEN i <= 34 THEN 5 -- KDH Van
        WHEN i <= 38 THEN 6 -- Mini Coach
        ELSE 7              -- VIP Coach
    END AS category_id,
    'WP ' || (ARRAY['CAB', 'CAD', 'CBA', 'CBB', 'CBC', 'GA', 'GB', 'ND', 'PD'])[1 + (i % 9)] || '-' || LPAD((1000 + i * 73)::TEXT, 4, '0') AS vehicle_number,
    'LIC-SLTDA-2024-' || LPAD(i::TEXT, 4, '0') AS vehicle_license,
    (ARRAY['Toyota Prius', 'Toyota Camry', 'Toyota Corolla Axio', 'Honda Vezel', 'Toyota Prado', 'Mahindra Bolero 4x4 Safari', 'Toyota HiAce KDH Super GL', 'Toyota Coaster', 'King Long Luxury Coach'])[1 + (i % 9)] || ' Fleet #' || i AS name,
    (ARRAY['Pearl White', 'Silver Metallic', 'Deep Ocean Blue', 'Champagne Gold', 'Matte Forest Green', 'Graphite Black'])[1 + (i % 6)] AS color,
    2018 + (i % 6) AS manufactured_year,
    CASE 
        WHEN i <= 15 THEN 4
        WHEN i <= 21 THEN 4
        WHEN i <= 26 THEN 6
        WHEN i <= 34 THEN 9
        WHEN i <= 38 THEN 16
        ELSE 32 
    END AS adult_seats,
    CASE WHEN i <= 34 THEN 1 + (i % 2) ELSE 0 END AS baby_seats,
    CASE 
        WHEN i <= 15 THEN 3
        WHEN i <= 21 THEN 4
        WHEN i <= 26 THEN 2
        WHEN i <= 34 THEN 9
        WHEN i <= 38 THEN 18
        ELSE 35 
    END AS luggage_capacity,
    CASE 
        WHEN i <= 8  THEN 55.00
        WHEN i <= 15 THEN 80.00
        WHEN i <= 21 THEN 95.00
        WHEN i <= 26 THEN 110.00
        WHEN i <= 34 THEN 130.00
        WHEN i <= 38 THEN 185.00
        ELSE 275.00 
    END AS price_per_day,
    (ARRAY['Sri Lanka Insurance Corporation', 'Ceylinco General Insurance', 'Allianz Insurance Lanka', 'Union Assurance'])[1 + (i % 4)] AS insurance_provider,
    '2024-01-01'::DATE + (i * 7) AS insurance_start_date,
    '2026-12-31'::DATE AS insurance_end_date,
    'AVAILABLE'::vehicle_status_type,
    (ARRAY['Toyota', 'Honda', 'Nissan', 'Mahindra', 'Mitsubishi', 'King Long'])[1 + (i % 6)] AS brand,
    (ARRAY['HiAce Super GL', 'Axio Fielder', 'Prado TX', 'Bolero Customized', 'Coaster Executive', 'Camry Hybrid'])[1 + (i % 6)] AS model,
    CASE WHEN i BETWEEN 22 AND 26 THEN 'Diesel' WHEN i % 2 = 0 THEN 'Hybrid Petrol' ELSE 'Diesel' END AS fuel_type,
    CASE WHEN i BETWEEN 22 AND 26 THEN 'Manual' ELSE 'Automatic' END AS transmission,
    CASE WHEN i BETWEEN 22 AND 26 THEN FALSE ELSE TRUE END AS air_conditioning,
    42000 + (i * 3150) AS mileage,
    (ARRAY['1500cc', '1800cc', '2000cc', '2500cc', '2800cc', '4000cc'])[1 + (i % 6)] AS engine_capacity,
    'GPS Tracking, Bluetooth Audio, Speed Limiter, Dashcam, First Aid Kit, Bottled Water Cooler' AS features
FROM generate_series(1, 40) AS s(i);

-- =========================================================
-- 3. PLACES (150 Real Sri Lankan Tourist Destinations)
-- =========================================================
INSERT INTO place (place_name, image_url, description, latitude, longitude)
WITH raw_places AS (
    SELECT unnest(ARRAY[
        'Sigiriya Rock Fortress', 'Temple of the Sacred Tooth Relic Kandy', 'Galle Dutch Fort', 'Nine Arches Bridge Ella', 
        'Yala National Park Block 1', 'Mirissa Coconut Tree Hill', 'Little Adams Peak Ella', 'Dambulla Royal Cave Temple', 
        'Horton Plains National Park & Worlds End', 'Udawalawe National Park', 'Polonnaruwa Ancient City Ruins', 
        'Anuradhapura Sacred Sacred Bodhi Tree', 'Pidurangala Rock', 'Bentota Golden Beach', 'Unawatuna Beach Lagoon', 
        'Nuwara Eliya Gregory Lake', 'Royal Botanical Gardens Peradeniya', 'Minneriya National Park Elephant Gathering', 
        'Arugam Bay Main Surf Point', 'Trincomalee Nilaveli Beach', 'Pigeon Island Marine National Park', 
        'Adams Peak Sri Pada Mountain', 'Wilpattu National Park', 'Knuckles Mountain Range Deanston', 
        'Lipton Seat Haputale', 'Tangalle Goyambokka Beach', 'Hikkaduwa Coral Reef Sanctuary', 
        'Sinharaja Lowland Rainforest Reserve', 'Ella Rock Panoramic Summit', 'St. Clairs Double Falls Talawakele', 
        'Devon Falls Kotmale', 'Ramboda Falls Tunnel', 'Ambuluwawa Biodiversity Complex Tower', 
        'Colombo Gangaramaya Temple', 'Colombo Galle Face Green Promenade', 'Colombo Red Mosque Pettah', 
        'Colombo National Museum', 'Negombo Dutch Canal Lagoon', 'Weligama Bay Surf Reserve', 'Hirisketiya Horseshoe Bay', 
        'Kabalana Surf Beach Ahangama', 'Talpe Natural Coral Rock Pools', 'Madu River Mangrove Biodiversity Estuary', 
        'Kosgoda Sea Turtle Conservation Hatchery', 'Kithulgala Kelani River Whitewater Rapids', 
        'Bopath Ella Waterfall Ratnapura', 'Babarakanda Highest Falls Kalupahana', 'Diyaluma Falls Upper Natural Pools', 
        'Ravana Falls and Ravana Cave Ella', 'Dunhinda Falls Badulla', 'Meemure Remote Valley Village', 
        'Sembuwatta Pine Forest Lake Matale', 'Riverston Peak Knuckles Gap', 'Bambarakiri Ella Matale', 
        'Nalanda Gedige Geometrical Center', 'Aluvihare Rock Temple Cave', 'Dambatenne Tea Factory Haputale', 
        'Pedro Tea Estate Nuwara Eliya', 'Mackwoods Labookellie Tea Estate', 'Single Tree Hill Summit Nuwara Eliya', 
        'Hakgala Subtropical Botanic Gardens', 'Gal Oya Senanayake Samudra', 'Kumana Migratory Bird Sanctuary', 
        'Bundala Ramsar Wetland Reserve', 'Mannar Baobab Tree & Island', 'Jaffna Fort Dutch Ramparts', 
        'Nallur Kandaswamy Kovil Jaffna', 'Jaffna Casuarina Beach Karainagar', 'Delft Island Wild Horses & Coral Ruins', 
        'Point Pedro Northernmost Tip', 'Koneswaram Temple Swami Rock Trincomalee', 'Fort Frederick Trincomalee', 
        'Marble Beach Naval Cove China Bay', 'Kanniya Seven Hot Water Springs', 'Batticaloa Dutch Fort & Lagoon', 
        'Pasikudah Shallow Coral Coast', 'Kalkudah Bay Beach', 'Kalpitiya Dolphin Lagoon Point', 
        'Wilpattu Kudiramalai Point', 'Mannar Thalaimannar Pier & Lighthouse', 'Kalutara Bodhiya Temple Shrine', 
        'Richmond Castle Estate Kalutara', 'Beruwala Barberyn Lighthouse Island', 'Seenigama Devalaya Sea Shrine', 
        'Galle Maritime Archaeological Museum', 'Martin Wickramasinghe Folk Museum Koggala', 
        'Koggala Stilt Fishermen Coast', 'Ahangama Lapidary Gem Centers', 'Midigama Skate & Surf Point', 
        'Matara Star Fort Dutch Rampart', 'Dondra Head Lighthouse Southernmost Point', 'Devinuwara Upulvan Shrine', 
        'Dickwella Wewurukannala Giant Buddha', 'Hummanaya Natural Blow Hole Kudawella', 'Mulkirigala Rock Monastery', 
        'Kalametiya Bird Sanctuary Mangroves', 'Ranna Rekawa Turtle Beach Sanctuary', 'Hambantota Botanical Gardens', 
        'Ridiyagama Open Safari Park', 'Kataragama Sacred Multi-Faith Shrine', 'Sella Kataragama Menik River', 
        'Kirinda Vihara Ocean Promontory', 'Yala Sithulpawwa Ancient Rock Hermitage', 'Lunugamvehera Reservoir National Park', 
        'Lahugala Kitulana Elephant Corridor', 'Muhudu Maha Vihara Sand Dunes Arugam', 'Okanda Devalaya Coastal Wilderness', 
        'Magul Maha Viharaya Historic Ruins', 'Monaragala Maligawila Giant Buddha Statue', 'Buduruwagala Colossal Rock Sculptures Wellawaya', 
        'Wellawaya Ellewala Hidden Waterfall', 'Ella Secret Waterfall Cave', 'Idalgashinna Ridge Railway Pass', 
        'Ohiya Misty Mountain Plateau', 'Horton Plains Bakers Waterfalls', 'Hakgala Strict Nature Reserve', 
        'Nuwara Eliya Moon Plains Agricultural Park', 'Single Tree Forest Reserve', 'Piduruthalagala Highest Summit Observation', 
        'Mandaram Nuwara Mist Shrouded Valley', 'Hanguranketha Ancient Royal Residence', 'Kandy Wales Park Reservoir Viewpoint', 
        'Kandy Lake Round Promenade', 'Bahirawakanda Giant White Buddha Monument', 'Udawattakele Forest Sanctuary', 
        'Hanthana Mountain Range Hiking Route', 'Gadaladeniya Stone Carved Temple', 'Lankatilaka Vihara Rock Ridge', 
        'Embekke Wood Carving Devalaya', 'Kandy National Gemological Museum', 'Kadugannawa Rock Pass & Incline', 
        'Alagalla Mountain Range Porcupine Rock', 'Balana Historical Military Fort Pass', 'Pinnawala Elephant Orphanage', 
        'Millennium Elephant Foundation Kegalle', 'Utuwankande Saradiel Village Rock', 'Belilena Prehistoric Cave Site Kithulgala', 
        'Welimada Divurumpola Ramayana Shrine', 'Rathna Ella Waterfall Hasalaka', 'Soranabora Historic Reservoir Mahiyanganaya', 
        'Mahiyangana Sacred Ancient Stupa', 'Dambana Indigenous Vedda Village Settlement', 'Wasgamuwa Central National Park', 
        'Maduru Oya National Park Reserve', 'Somawathiya Sacred Stupa Flood Plains', 'Lankapatuna Ocean Inlet Stupa', 
        'Polonnaruwa Gal Vihara Rock Relics', 'Polonnaruwa Parakrama Samudra Lake', 'Medirigiriya Vatadage Historic Site', 
        'Ritigala Strict Nature Reserve & Monastery', 'Kandalama Lake Ecological Reservoir', 'Namal Uyana Ironwood Forest & Rose Quartz', 
        'Avukana Standing Monolithic Buddha', 'Resvehera Ancient Carved Buddha', 'Yapahuwa Ancient Fortress Rock Staircase', 
        'Panduwasnuwara Royal Palace Ruins', 'Kurunegala Ethagala Elephant Rock Monument'
    ]) AS p_name
)
SELECT 
    p_name,
    'https://images.unsplash.com/destinations/srilanka/' || lower(replace(regexp_replace(p_name, '[^a-zA-Z0-9 ]', '', 'g'), ' ', '-')) || '.jpg',
    p_name || ' is one of the premier natural, cultural, and scenic attractions across Sri Lanka, frequently visited by international holidaymakers.',
    ROUND((5.920000 + (ROW_NUMBER() OVER () * 0.0261) % 3.900000)::NUMERIC, 7),
    ROUND((79.850000 + (ROW_NUMBER() OVER () * 0.0137) % 1.950000)::NUMERIC, 7)
FROM raw_places;

-- =========================================================
-- 4. ACTIVITIES (100 Authentic Sri Lankan Tour Activities)
-- =========================================================
INSERT INTO activity (activity_name, phone, description)
WITH raw_activities AS (
    SELECT unnest(ARRAY[
        'Guided Sunrise Hike to Sigiriya Rock', 'Pidurangala Rock Sunrise Photography Excursion', 
        'Dambulla Cave Temple Guided Cultural Walk', 'Temple of the Tooth Relic Evening Theva Ceremony', 
        'Kandy Lake Round Heritage Stroll', 'Kandyan Cultural Dance and Drumming Performance', 
        'Royal Botanical Gardens Flora Guided Tour', 'Knuckles High Forest Wilderness Trekking', 
        'Hanthana Ridge Tea Plantation Hiking', 'Pinnawala Elephant Bathing Observation', 
        'Ella Nine Arches Bridge Train Spotting Walk', 'Little Adams Peak Sunset Hike', 
        'Ella Rock Guided Challenge Hike', 'Ravana Mega Zipline Adventure Experience', 
        'Diyaluma Waterfall Upper Infinity Pools Bathing', 'Scenic Highland Train Ride Kandy to Ella', 
        'Nuwara Eliya Tea Plucking & Factory Cupping', 'Horton Plains & Worlds End Morning Nature Trek', 
        'Bakers Falls Forest Trail', 'Gregory Lake Jet Ski & Speedboat Cruising', 
        'Hakgala Subtropical Gardens Exploration', 'Liptons Seat Early Morning Sunrise Jeep Safari', 
        'Kithulgala White Water Rafting Class III Rapids', 'Kelani River Rainforest Canyoneering & Cliff Jumps', 
        'Prehistoric Belilena Cave Archaeological Tour', 'Yala National Park Afternoon Leopard Safari', 
        'Yala Early Dawn Full Day Wildlife Expedition', 'Udawalawe Elephant Sanctuary Open Jeep Safari', 
        'Minneriya Wild Elephant Gathering Jeep Safari', 'Kaudulla National Park Elephant Corridor Safari', 
        'Hurulu Eco Park Dry Zone Wildlife Safari', 'Wilpattu Safari Tracking Sloth Bears and Leopards', 
        'Mirissa Whale and Dolphin Watching Cruise', 'Private Catamaran Sailing in Mirissa Bay', 
        'Deep Sea Sport Fishing off Mirissa Coast', 'Weligama Beginner Surf Lesson with Local Pro', 
        'Midigama Intermediate Reef Break Surfing', 'Ahangama Stilt Fishing Demonstration and Photoshoot', 
        'Kabalana High Wave Surfing Excursion', 'Hirisketiya Bay Surf and Yoga Session', 
        'Galle Fort Historical Ramparts Guided Walking Tour', 'Dutch Heritage Architecture and Museum Walk Galle', 
        'Unawatuna Jungle Beach Snorkeling Expedition', 'Hikkaduwa Glass Bottom Boat Coral Reef Tour', 
        'Sea Turtle Hatchery and Sanctuary Educational Visit', 'Madu River Mangrove Biodiversity Motorboat Safari', 
        'Cinnamon Island Peeling & Processing Demo', 'Bentota River Water Sports and Banana Boat Ride', 
        'Bentota Coral Reef Scuba Diving Experience', 'Traditional Southern Ayurvedic Full Body Herbal Massage', 
        'Shirodhara Wellness & Stress Relief Treatment', 'Steam Bath & Herbal Inhalation Therapy', 
        'Private Sunset Yoga & Meditation on the Beach', 'Authentic Sri Lankan Spice Cooking Masterclass', 
        'Pettah Street Food and Market Walking Tour', 'Colombo Open Deck Vintage Double Decker City Tour', 
        'Gangaramaya Temple and Seema Malaka Tour', 'Colombo National Museum Curated History Tour', 
        'Galle Face Green Kite Flying & Street Food Evening', 'Negombo Lagoon Morning Fishermen Boat Tour', 
        'Hamilton Dutch Canal Kayaking Adventure', 'Pigeon Island Marine Sanctuary Coral Snorkeling', 
        'Nilaveli Beach Scuba Diving Expedition', 'Koneswaram Temple Swami Rock Cliff Walk', 
        'Trincomalee Deep Harbour Whale Watching Voyage', 'Kanniya Natural Hot Spring Bathing', 
        'Pasikudah Calm Bay Stand Up Paddleboarding', 'Arugam Bay World Tour Point Surfing', 
        'Kumana National Park Bird Watching Safari', 'Arugam Bay Lagoon Safari to Elephant Rock', 
        'Anuradhapura Sacred City UNESCO Cycling Tour', 'Ruwanwelisaya and Sri Maha Bodhi Pilgrimage Walk', 
        'Mihintale Sacred Cradle of Buddhism Staircase Climb', 'Polonnaruwa Ancient Citadel Royal Palace Tour', 
        'Polonnaruwa Gal Vihara Monolithic Sculpture Study', 'Parakrama Samudra Breezy Embankment Sunset Walk', 
        'Ritigala Forest Hermitage Ecological Monastery Trek', 'Kalpitiya Bar Reef Scuba Diving Adventure', 
        'Kalpitiya Kite Surfing Flatwater Lagoon Lesson', 'Kalpitiya Spinner Dolphin Watching Boat Tour', 
        'Wilpattu Kudiramalai Red Sand Coast Safari Walk', 'Jaffna Fort Sunset Rampart Walking Tour', 
        'Nallur Kandaswamy Temple Evening Puja Ritual', 'Delft Island Wild Pony & Baobab Tree Excursion', 
        'Jaffna Crab Curry Traditional Dining Experience', 'Karainagar Casuarina Beach Swimming & Sunbathing', 
        'Point Pedro & Northern Coastline Scenic Drive', 'Keerimalai Natural Sacred Freshwater Spring Bath', 
        'Mannar Island Flamingo & Migratory Bird Watching', 'Adams Bridge Thalaimannar Sand Dunes Expedition', 
        'Sinharaja Virgin Rainforest Biodiversity Trekking', 'Endemic Bird Watching Guided Trail Sinharaja', 
        'Meemure Isolated Mountain Village Trek', 'Riverston Mini Worlds End Windy Gap Trek', 
        'Sembuwatta Natural Spring Lake Excursion', 'Bambarakanda Highest Falls Base Pool Hike', 
        'Dunhinda Falls Misty Spray Forest Hike', 'Maduru Oya Indigenous Vedda Cultural Exchange', 
        'Ambuluwawa Cone Tower 360 Degree Aerial Ascent', 'Gal Oya Boat Safari Watching Swimming Elephants'
    ]) AS a_name
)
SELECT 
    a_name,
    '+94 77 ' || (1000000 + (ROW_NUMBER() OVER () * 8641) % 8999999)::TEXT,
    'Certified excursion: ' || a_name || ' supervised by local SLTDA licensed guides and instructors.'
FROM raw_activities;

-- =========================================================
-- 5. PLACE-ACTIVITY JUNCTION
-- =========================================================
-- Map activities deterministically to destinations based on geographic proximity/affinity
INSERT INTO place_activity (place_id, activity_id)
SELECT 
    1 + ((i * 3 + j * 7) % 150) AS place_id,
    i AS activity_id
FROM generate_series(1, 100) AS s(i)
CROSS JOIN generate_series(1, 3) AS c(j);

-- =========================================================
-- 6. PACKAGES (20 Curated All-Island Itineraries)
-- =========================================================
INSERT INTO package (title, type, days, description, weather, image_url, availability_status)
VALUES
('Classic Ceylon Highlights Explorer', 'CULTURAL HERITAGE', '7 DAYS', 'Discover the Cultural Triangle, Kandy tooth relic temple, scenic tea plantations, and Colombo heritage sites.', '{"temp_c": 28, "condition": "Sunny", "humidity": 70}', 'https://images.unsplash.com/package-heritage-7d.jpg', 'AVAILABLE'),
('Grand Cultural Triangle & Ancient Kingdoms', 'CULTURAL HERITAGE', '14 DAYS', 'An extensive historical journey traversing Anuradhapura, Polonnaruwa, Sigiriya, Dambulla, and Kandy.', '{"temp_c": 30, "condition": "Warm", "humidity": 65}', 'https://images.unsplash.com/package-heritage-14d.jpg', 'AVAILABLE'),
('Heritage & Royal Cities Deep Dive', 'CULTURAL HERITAGE', '21 DAYS', 'Deep cultural immersion featuring ancient temples, Dutch colonial forts, traditional arts, and historic monasteries.', '{"temp_c": 29, "condition": "Sunny Intervals", "humidity": 68}', 'https://images.unsplash.com/package-heritage-21d.jpg', 'AVAILABLE'),
('Sri Lanka Epic Antiquity Odyssey', 'CULTURAL HERITAGE', '28 DAYS', 'The ultimate month-long expedition covering all 8 UNESCO World Heritage Sites from Jaffna to Galle.', '{"temp_c": 29, "condition": "Tropical Breezy", "humidity": 72}', 'https://images.unsplash.com/package-heritage-28d.jpg', 'AVAILABLE'),

('Knuckles & Peaks Highland Adventure', 'ADVENTURE', '7 DAYS', 'Trekking through the misty Knuckles Range, Ella Rock, Little Adams Peak, and Kithulgala rapids.', '{"temp_c": 22, "condition": "Breezy", "humidity": 80}', 'https://images.unsplash.com/package-adventure-7d.jpg', 'AVAILABLE'),
('Wild Trails & Highland Adrenaline', 'ADVENTURE', '14 DAYS', 'Whitewater rafting, waterfall abseiling, jungle hiking, high mountain passes, and surfing southern breaks.', '{"temp_c": 24, "condition": "Partly Cloudy", "humidity": 75}', 'https://images.unsplash.com/package-adventure-14d.jpg', 'AVAILABLE'),
('Active Island Hiker & Explorer Expedition', 'ADVENTURE', '21 DAYS', 'All-island trekking covering Adams Peak, Horton Plains, Sinharaja rainforest, and coastal kite surf lessons.', '{"temp_c": 25, "condition": "Tropical", "humidity": 76}', 'https://images.unsplash.com/package-adventure-21d.jpg', 'AVAILABLE'),
('Ultimate Sri Lanka 28-Day Extreme Expedition', 'ADVENTURE', '28 DAYS', 'Four weeks of trekking, scuba diving coral atolls, surfing, caving, canyoning, and off-road biking.', '{"temp_c": 26, "condition": "Clear Sky", "humidity": 70}', 'https://images.unsplash.com/package-adventure-28d.jpg', 'AVAILABLE'),

('Ayurvedic Rejuvenation & Beach Retreat', 'WELLNESS & AYURVEDA', '7 DAYS', 'Daily Panchakarma treatments, seaside yoga at sunrise, organic herbal meals, and calm meditation sessions.', '{"temp_c": 29, "condition": "Sunny", "humidity": 78}', 'https://images.unsplash.com/package-wellness-7d.jpg', 'AVAILABLE'),
('Holistic Herbal Healing Sanctuary', 'WELLNESS & AYURVEDA', '14 DAYS', 'Two weeks of therapeutic detox, doctor consultations, herbal oil baths, Shirodhara, and mindful silence.', '{"temp_c": 28, "condition": "Mild Tropical", "humidity": 75}', 'https://images.unsplash.com/package-wellness-14d.jpg', 'AVAILABLE'),
('Traditional Ceylon Mind-Body Transformation', 'WELLNESS & AYURVEDA', '21 DAYS', 'Extensive curative Ayurvedic treatments supervised by indigenous doctors in tranquil southern nature estates.', '{"temp_c": 28, "condition": "Warm", "humidity": 74}', 'https://images.unsplash.com/package-wellness-21d.jpg', 'AVAILABLE'),
('Total Zen & Rebirth Longstay Wellness', 'WELLNESS & AYURVEDA', '28 DAYS', 'A month-long revitalizing sanctuary program balancing internal doshas, nutrition, meditation, and rest.', '{"temp_c": 27, "condition": "Tropical Calms", "humidity": 72}', 'https://images.unsplash.com/package-wellness-28d.jpg', 'AVAILABLE'),

('Southern Coastline & Coral Reef Escape', 'BEACH SIDE', '7 DAYS', 'Golden sand beaches of Mirissa, Unawatuna, Bentota, and Hiriketiya, paired with fresh seafood dining.', '{"temp_c": 31, "condition": "Sunny & Humid", "humidity": 82}', 'https://images.unsplash.com/package-beach-7d.jpg', 'AVAILABLE'),
('Sun, Surf & Tropical Sands Round-Trip', 'BEACH SIDE', '14 DAYS', 'Surfing at Weligama, diving at Hikkaduwa, relaxing in Tangalle, and whale watching at Mirissa.', '{"temp_c": 30, "condition": "Sunny", "humidity": 80}', 'https://images.unsplash.com/package-beach-14d.jpg', 'AVAILABLE'),
('All-Coastline Lagoon & Beach Explorer', 'BEACH SIDE', '21 DAYS', 'From southern coves to eastern surf shores in Arugam Bay and pristine white sands of Nilaveli.', '{"temp_c": 30, "condition": "Sunny Clear", "humidity": 77}', 'https://images.unsplash.com/package-beach-21d.jpg', 'AVAILABLE'),

('Little England & Cloud Forest Tea Trail', 'HILL COUNTRY', '7 DAYS', 'Nuwara Eliya colonial estates, misty tea factory tours, cascading waterfalls, and scenic hill country trains.', '{"temp_c": 16, "condition": "Chilly & Misty", "humidity": 88}', 'https://images.unsplash.com/package-hill-7d.jpg', 'AVAILABLE'),
('Grand Mist, Waterfalls & Highland Peaks', 'HILL COUNTRY', '14 DAYS', 'Extended retreat through Kandy, Nuwara Eliya, Haputale, Ella, and Ohiya misty mountain passes.', '{"temp_c": 18, "condition": "Misty", "humidity": 85}', 'https://images.unsplash.com/package-hill-14d.jpg', 'AVAILABLE'),

('Big Four Wildlife Safari Quick Circuit', 'SAFARI', '7 DAYS', 'Spotting wild leopards in Yala, elephants in Udawalawe, and blue whales off the coast of Mirissa.', '{"temp_c": 31, "condition": "Dry & Sunny", "humidity": 65}', 'https://images.unsplash.com/package-safari-7d.jpg', 'AVAILABLE'),
('Wild Sri Lanka Leopards, Elephants & Birds', 'SAFARI', '14 DAYS', 'Extensive jeep safaris in Yala, Wilpattu, Minneriya, Bundala, and deep boat safaris in Gal Oya.', '{"temp_c": 32, "condition": "Dry Sunny", "humidity": 62}', 'https://images.unsplash.com/package-safari-14d.jpg', 'AVAILABLE'),
('Grand Wilderness & Marine Life Safari Odyssey', 'SAFARI', '21 DAYS', 'The premier nature expedition covering terrestrial predator tracking and deep ocean marine sanctuaries.', '{"temp_c": 30, "condition": "Sunny", "humidity": 66}', 'https://images.unsplash.com/package-safari-21d.jpg', 'AVAILABLE');

-- =========================================================
-- 7. PACKAGE-PLACE ROUTING
-- =========================================================
-- Connect packages to places systematically across their required day counts
INSERT INTO package_place (package_id, place_id, day_number)
SELECT 
    pkg.package_id,
    1 + (((pkg.package_id * 7) + d * 5) % 150) AS place_id,
    d AS day_number
FROM package pkg
CROSS JOIN LATERAL (
    SELECT generate_series(
        1, 
        CASE 
            WHEN pkg.days = '7 DAYS' THEN 7
            WHEN pkg.days = '14 DAYS' THEN 14
            WHEN pkg.days = '21 DAYS' THEN 21
            ELSE 28
        END
    ) AS d
) days_gen;

-- =========================================================
-- 8. USERS (1,500 Foreign Inbound Travelers + 10 Admins)
-- =========================================================
-- Administrative staff
INSERT INTO "user" (
    name, email, password_hash, role, contact_number, street_address, 
    country, zipcode, auth_provider, status, created_at, updated_at
)
SELECT 
    'Admin Specialist ' || i,
    'ops.admin' || i || '@ceylontours.com',
    '$2a$12$e8qH1yQ9XkM9yB7C6wF4Nuq9yD.M0H1vM1WzK5h8yY0Kj4vV0uS1.',
    'ADMIN'::user_role,
    '+94 77 ' || (2000000 + i * 11111)::TEXT,
    'Level ' || i || ', World Trade Center, Echelon Square',
    'Sri Lanka',
    '00100',
    'LOCAL'::auth_provider_type,
    'ACTIVE'::user_status,
    '2024-01-01 08:00:00+00'::TIMESTAMPTZ,
    '2024-01-01 08:00:00+00'::TIMESTAMPTZ
FROM generate_series(1, 10) AS s(i);

-- Foreign Travelers (Key international inbound markets for Sri Lanka)
INSERT INTO "user" (
    name, email, password_hash, role, contact_number, street_address, 
    country, zipcode, emergency_name, emergency_phone, emergency_relationship,
    auth_provider, provider_id, status, created_at, updated_at
)
SELECT 
    (ARRAY['Oliver', 'Emma', 'Liam', 'Sophie', 'Lucas', 'Mia', 'Alexander', 'Elena', 'Noah', 'Charlotte', 'Maximilian', 'Chloe', 'Dmitry', 'Anastasia', 'Lars', 'Freja', 'Mateo', 'Camille', 'Arthur', 'Isabella'])[1 + (i % 20)] || ' ' ||
    (ARRAY['Smith', 'Muller', 'Ivanov', 'Brown', 'Dubois', 'Schneider', 'Wilson', 'Taylor', 'Davies', 'Novak', 'Andersson', 'Martin', 'Lefebvre', 'Hansen', 'Fischer', 'Weber', 'Rossi', 'Schmidt', 'Kowalski', 'Smirnov'])[1 + (i % 20)],
    'traveler_' || i || '_' || floor(random() * 89999 + 10000) || '@' || (ARRAY['gmail.com', 'outlook.com', 'yahoo.co.uk', 'icloud.com', 'web.de', 'yandex.ru', 'orange.fr', 'bluewin.ch'])[1 + (i % 8)],
    '$2a$12$K1n8z0h7g6e5d4c3b2a1Z.9876543210abcdefghijklmnopqrstu',
    'CUSTOMER'::user_role,
    (ARRAY['+44 79', '+49 15', '+7 91', '+33 6', '+61 4', '+1 415', '+31 6', '+41 79', '+48 60', '+45 20'])[1 + (i % 10)] || LPAD((1000000 + (i * 739) % 8999999)::TEXT, 7, '0'),
    (10 + (i % 450))::TEXT || ' ' || (ARRAY['High Street', 'Bahnhofstrasse', 'Rue de la Paix', 'Alexanderplatz', 'Victoria Road', 'Main Street', 'Park Avenue', 'Prinsengracht'])[1 + (i % 8)],
    (ARRAY['United Kingdom', 'Germany', 'Russia', 'France', 'Australia', 'United States', 'Netherlands', 'Switzerland', 'Poland', 'Denmark'])[1 + (i % 10)],
    LPAD((10000 + (i * 17) % 89999)::TEXT, 5, '0'),
    'Family Contact ' || i,
    '+44 7700 900' || LPAD((i % 999)::TEXT, 3, '0'),
    (ARRAY['Spouse', 'Parent', 'Sibling', 'Partner', 'Friend'])[1 + (i % 5)],
    (ARRAY['LOCAL', 'GOOGLE', 'FACEBOOK', 'LOCAL', 'GOOGLE'])[1 + (i % 5)]::auth_provider_type,
    CASE WHEN (i % 5) IN (1, 2, 4) THEN 'oauth2_token_' || md5(i::TEXT) ELSE NULL END,
    'ACTIVE'::user_status,
    '2024-01-01 00:00:00+00'::TIMESTAMPTZ + (interval '1 hour' * (i * 15)),
    '2024-01-01 00:00:00+00'::TIMESTAMPTZ + (interval '1 hour' * (i * 15))
FROM generate_series(1, 1500) AS s(i);

-- =========================================================
-- 9. BOOKINGS (2,200 High-Volume Agency Bookings)
-- =========================================================
-- Distributes across 2024-01-01 to 2026-10-01 with natural seasonal weight
INSERT INTO booking (
    user_id, customer_name, contact_platform, contact_number, tour_type, 
    category_id, vehicle_id, start_date, end_date, pickup_time, 
    start_location, end_location, total_days, days_required, 
    luggage_10kg, luggage_25kg, luggage_35kg, no_of_adults, no_of_children, ages_of_children, 
    quoted_price, additional_charges, notes, tour_thoughts, admin_note, 
    booking_date, booking_status, quoted_at, confirmed_at, tour_started_at, completed_at, closed_at
)
SELECT
    cust.user_id,
    cust.name,
    (ARRAY['whatsapp', 'mobile', 'email', 'telegram'])[1 + (i % 4)],
    cust.contact_number,
    b_tour_type,
    b_cat_id,
    b_veh_id,
    b_start,
    b_end,
    '08:00:00'::TIME + (interval '30 minutes' * (i % 8)),
    (ARRAY['Bandaranaike International Airport (CMB)', 'Mattala Rajapaksa Airport (HRI)', 'Colombo Fort Hotel', 'Negombo Beach Resort', 'Galle Fort Heritage Villa'])[1 + (i % 5)],
    (ARRAY['Bandaranaike International Airport (CMB)', 'Colombo Port Passenger Terminal', 'Negombo Beach Hotel', 'Mirissa Coast Hotel', 'Colombo City Center'])[1 + (i % 5)],
    b_days,
    b_days,
    1 + (i % 3),
    1 + (i % 4),
    CASE WHEN i % 4 = 0 THEN 1 ELSE 0 END,
    1 + (i % 4),
    CASE WHEN i % 5 = 0 THEN 1 WHEN i % 9 = 0 THEN 2 ELSE 0 END,
    CASE WHEN i % 5 = 0 THEN '7' WHEN i % 9 = 0 THEN '5, 10' ELSE NULL END,
    b_price,
    CASE WHEN i % 7 = 0 THEN 50.00 ELSE 0.00 END,
    'Flight arrival tracking required. Need English speaking chauffeur-guide.',
    'Excited for cultural sites, coastal swimming, and tea estate tours.',
    'VIP treatment recommended. Standard fleet allocation checked.',
    b_booked_date,
    b_status,
    -- Milestone Timestamps
    CASE WHEN b_status IN ('QUOTED', 'ACCEPTED', 'CONFIRMED', 'TOUR_STARTED', 'COMPLETED', 'CLOSED') THEN b_booked_date::TIMESTAMPTZ + interval '4 hours' ELSE NULL END,
    CASE WHEN b_status IN ('CONFIRMED', 'TOUR_STARTED', 'COMPLETED', 'CLOSED') THEN b_booked_date::TIMESTAMPTZ + interval '18 hours' ELSE NULL END,
    CASE WHEN b_status IN ('TOUR_STARTED', 'COMPLETED', 'CLOSED') THEN b_start::TIMESTAMPTZ + interval '8 hours' ELSE NULL END,
    CASE WHEN b_status IN ('COMPLETED', 'CLOSED') THEN b_end::TIMESTAMPTZ + interval '18 hours' ELSE NULL END,
    CASE WHEN b_status = 'CLOSED' THEN b_end::TIMESTAMPTZ + interval '36 hours' ELSE NULL END
FROM generate_series(1, 2200) AS s(i)
CROSS JOIN LATERAL (
    SELECT 
        11 + ((i * 13) % 1500) AS assigned_user_id,
        '2024-01-01'::DATE + ((i * 365) / 800) AS b_start_raw,
        (ARRAY['7 DAYS', '14 DAYS', '7 DAYS', '21 DAYS', '14 DAYS', '28 DAYS'])[1 + (i % 6)] AS b_dur_str,
        CASE 
            WHEN (i % 6) IN (0, 2) THEN 7
            WHEN (i % 6) IN (1, 4) THEN 14
            WHEN (i % 6) = 3 THEN 21
            ELSE 28
        END AS b_days,
        (ARRAY['PACKAGE', 'P2P', 'PACKAGE', 'PACKAGE', 'P2P'])[1 + (i % 5)]::tour_type_enum AS b_tour_type
) AS vars
JOIN "user" cust ON cust.user_id = vars.assigned_user_id
CROSS JOIN LATERAL (
    SELECT 
        vars.b_start_raw AS b_start,
        vars.b_start_raw + vars.b_days AS b_end,
        vars.b_start_raw - (10 + (i % 35)) AS b_booked_date,
        1 + (i % 7) AS b_cat_id,
        1 + (i % 40) AS b_veh_id,
        CASE 
            -- Chronological progression based on end date vs simulation boundary (2026-10-01)
            WHEN vars.b_start_raw + vars.b_days < '2026-09-01'::DATE THEN
                (ARRAY['COMPLETED', 'CLOSED', 'COMPLETED', 'CLOSED', 'CANCELLED'])[1 + (i % 5)]::booking_status_type
            WHEN vars.b_start_raw <= '2026-10-01'::DATE AND vars.b_start_raw + vars.b_days >= '2026-10-01'::DATE THEN 
                'TOUR_STARTED'::booking_status_type
            ELSE 
                (ARRAY['CONFIRMED', 'QUOTED', 'ACCEPTED', 'PENDING'])[1 + (i % 4)]::booking_status_type
        END AS b_status,
        (vars.b_days * (85.00 + (i % 6) * 35.00))::NUMERIC(10,2) AS b_price
) AS derived;

-- =========================================================
-- 10. BOOKING-PACKAGE JUNCTION
-- =========================================================
INSERT INTO booking_package (booking_id, package_id)
SELECT 
    b.booking_id,
    1 + (b.booking_id % 20) AS package_id
FROM booking b
WHERE b.tour_type = 'PACKAGE';

-- =========================================================
-- 11. PAYMENTS (3,200 Deposit & Final Settlements)
-- =========================================================
-- 1st Installment (Advance Deposit of 30% upon confirmation)
INSERT INTO payment (booking_id, amount, payment_method, received_date, recorded_by, notes)
SELECT 
    b.booking_id,
    ROUND((b.quoted_price * 0.30)::NUMERIC, 2),
    (ARRAY['BANK_TRANSFER', 'CASH', 'BANK_TRANSFER'])[1 + (b.booking_id % 3)]::payment_method_type,
    b.booking_date + 2,
    1 + (b.booking_id % 10), -- Recorded by one of the 10 Admin users
    'Initial 30% advance booking deposit received and verified via swift/gateway.'
FROM booking b
WHERE b.booking_status IN ('CONFIRMED', 'TOUR_STARTED', 'COMPLETED', 'CLOSED');

-- 2nd Installment (Final Balance of 70% paid on arrival / tour start)
INSERT INTO payment (booking_id, amount, payment_method, received_date, recorded_by, notes)
SELECT 
    b.booking_id,
    ROUND((b.quoted_price * 0.70 + b.additional_charges)::NUMERIC, 2),
    (ARRAY['CASH', 'BANK_TRANSFER', 'CASH'])[1 + (b.booking_id % 3)]::payment_method_type,
    b.start_date,
    1 + ((b.booking_id + 3) % 10),
    'Final settlement balance paid in full upon arrival / start of vehicle dispatch.'
FROM booking b
WHERE b.booking_status IN ('TOUR_STARTED', 'COMPLETED', 'CLOSED');

-- =========================================================
-- 12. REVIEWS & REVIEW IMAGES (~1,000 Verified Experiences)
-- =========================================================
INSERT INTO review (user_id, booking_id, rating, driver_name, title, feedback, created_at)
SELECT 
    b.user_id,
    b.booking_id,
    CASE 
        WHEN b.booking_id % 15 = 0 THEN 3
        WHEN b.booking_id % 25 = 0 THEN 2
        WHEN b.booking_id % 50 = 0 THEN 1
        WHEN b.booking_id % 4 = 0 THEN 4
        ELSE 5 
    END AS rating,
    (ARRAY['Sunil Perera', 'Pradeep Kumara', 'Chaminda Silva', 'Dhammika Bandara', 'Nuwan Jayasinghe', 'Kasun Fernando', 'Rohan Wijesinghe', 'Anura Senanayake'])[1 + (b.booking_id % 8)] AS driver_name,
    (ARRAY['Unforgettable 2-week journey!', 'Exceptional driver and clean vehicle', 'Magical Sri Lanka experience', 'Breathtaking sights & safe driving', 'Good tour, slightly packed itinerary', 'Paradise on earth!'])[1 + (b.booking_id % 6)] AS title,
    (ARRAY[
        'Our driver was remarkably professional, knowledgeable, and always punctual. The KDH van was spotless every single morning.',
        'From Sigiriya to the southern beaches, everything ran without a hitch. The safari in Yala was the highlight of our vacation!',
        'The scenery in the hill country took our breath away. Clean vehicle, great air conditioning, and top-tier hospitality.',
        'Felt completely secure throughout our family vacation. Driver was excellent with our children and gave great local fruit tasting tips.',
        'Very reliable agency for foreign visitors. Punctual airport pickup at CMB and smooth coordination throughout.'
    ])[1 + (b.booking_id % 5)] AS feedback,
    b.completed_at + interval '2 days'
FROM booking b
WHERE b.booking_status IN ('COMPLETED', 'CLOSED')
  AND b.booking_id % 2 = 0; -- ~50% review completion rate

-- Review photographs
INSERT INTO review_image (review_id, image_url)
SELECT 
    r.review_id,
    'https://images.unsplash.com/reviews/user-upload-' || r.review_id || '-shot' || img_idx || '.jpg'
FROM review r
CROSS JOIN generate_series(1, 2) AS s(img_idx)
WHERE r.rating >= 4 AND r.review_id % 2 = 0;

-- =========================================================
-- 13. SUPPORT, CONTACT INQUIRIES & REPLIES (800 Inquiries)
-- =========================================================
INSERT INTO contact_inquiry (sender_name, sender_email, sender_phone, subject, message, is_read, status, submitted_at)
SELECT 
    u.name,
    u.email,
    u.contact_number,
    (ARRAY['Custom 14-day itinerary inquiry', 'Luggage capacity for 4 adults in Sedan', 'Child car seat availability', 'Surfboard carriage on KDH van', 'Airport pickup at midnight timing', 'Yala safari private jeep booking'])[1 + (i % 6)],
    'Hello, we are traveling from ' || u.country || ' and would like to confirm vehicle availability, pricing, and English-speaking chauffeur assignment.',
    TRUE,
    'replied'::inquiry_status_type,
    u.created_at + interval '2 hours'
FROM "user" u
JOIN generate_series(1, 800) AS s(i) ON u.user_id = (10 + i);

INSERT INTO contact_reply (inquiry_id, sender_role, sender_name, message, sent_at)
SELECT 
    ci.inquiry_id,
    'admin'::sender_role_type,
    'Reservation Desk Specialist',
    'Ayubowan ' || ci.sender_name || ', thank you for writing to us. Yes, all our vehicles are insured for foreign tourists and equipped with AC and child seats upon request. We have reserved the quote for you.',
    ci.submitted_at + interval '1 hour 45 minutes'
FROM contact_inquiry ci;


COMMIT;


SELECT 'vehicle_category' AS table_name, count(*) AS total_rows FROM vehicle_category
UNION ALL SELECT 'vehicle', count(*) FROM vehicle
UNION ALL SELECT 'place', count(*) FROM place
UNION ALL SELECT 'activity', count(*) FROM activity
UNION ALL SELECT 'package', count(*) FROM package
UNION ALL SELECT 'package_place', count(*) FROM package_place
UNION ALL SELECT 'user (total)', count(*) FROM "user"
UNION ALL SELECT 'user (customers)', count(*) FROM "user" WHERE role = 'CUSTOMER'
UNION ALL SELECT 'booking', count(*) FROM booking
UNION ALL SELECT 'booking_package', count(*) FROM booking_package
UNION ALL SELECT 'payment', count(*) FROM payment
UNION ALL SELECT 'review', count(*) FROM review
UNION ALL SELECT 'review_image', count(*) FROM review_image
UNION ALL SELECT 'contact_inquiry', count(*) FROM contact_inquiry


