BEGIN;

-- IMPORTANT: This is a synthetic demonstration dataset for development/testing.
-- Customer identities, contact details, vehicle registrations, fleet licence IDs,
-- insurance dates, bookings, payments and reviews are illustrative placeholders,
-- not records of real customers, vehicles, operators or transactions.
-- Destination names and approximate coordinates are based on known Sri Lankan places.
-- Vehicle rates are indicative sample LKR/day transport rates, not all-inclusive package prices;
-- confirm driver, fuel, mileage, meals, accommodation, taxes and insurance inclusions with suppliers.

-- =========================================================
-- 1. VEHICLE CATEGORIES (7 Sri Lanka-appropriate categories)
-- Passenger and luggage capacities are indicative; verify each actual vehicle.
-- Daily prices below are sample LKR rates, not a live quotation.
-- =========================================================
INSERT INTO vehicle_category (
    category_name, description, passenger_capacity, luggage_capacity,
    best_for, comfort_level, ac_available, ideal_trip_types
) VALUES
('Economy Sedan', 'Compact air-conditioned car suitable for up to 3 passengers with light luggage.', '1-3 Passengers', '2 Medium Bags', 'Solo travellers, couples, airport transfers', 'Standard', TRUE, 'Airport Transfers, Colombo City Trips, Short Intercity Trips'),
('Executive Sedan', 'Comfortable executive sedan for up to 3 passengers and moderate luggage.', '1-3 Passengers', '2-3 Medium Bags', 'Couples, business travellers, small families', 'Premium', TRUE, 'Airport Transfers, Cultural Triangle, Island Tours'),
('Compact SUV', 'Higher-clearance SUV or crossover suitable for hill-country and intercity travel.', '1-4 Passengers', '2-3 Medium Bags', 'Small families, couples, hill-country travel', 'High Comfort', TRUE, 'Hill Country, Intercity Travel, Family Trips'),
('Safari 4x4 Jeep', 'Open or pop-top 4x4 safari jeep operated by a park-authorised safari provider.', '1-6 Passengers', 'Daypacks Only', 'Wildlife visitors, photographers', 'Safari', FALSE, 'Yala, Udawalawe, Wilpattu, Minneriya, Kaudulla'),
('Tourist Van (HiAce/KDH)', 'Air-conditioned passenger van suitable for family and small-group tours.', '6-9 Passengers', '5-8 Medium Bags', 'Families, small groups', 'Comfort', TRUE, 'Airport Transfers, Multi-Day Island Tours'),
('Mini Coach', 'Air-conditioned mini coach for medium-sized tour groups.', '15-25 Passengers', 'Group Luggage', 'School, corporate and group travel', 'Executive', TRUE, 'Group Excursions, Multi-Day Tours'),
('Tourist Coach', 'Full-size air-conditioned coach for larger organised groups.', '26-45 Passengers', 'Underfloor Group Luggage', 'Large tour groups, events', 'Executive', TRUE, 'Group Tours, Events, Island Circuits');


-- =========================================================
-- 2. VEHICLES (40 synthetic sample fleet records)
-- Registration-like numbers and fleet IDs are demo placeholders, NOT real registrations/licences.
-- Prices are indicative LKR/day sample rates. Confirm inclusions and actual supplier quotations.
-- =========================================================
INSERT INTO vehicle (
    category_id, vehicle_number, vehicle_license, name, color, manufactured_year,
    adult_seats, baby_seats, luggage_capacity, price_per_day, insurance_provider,
    insurance_start_date, insurance_end_date, vehicle_status, brand, model,
    fuel_type, transmission, air_conditioning, mileage, engine_capacity, features
) VALUES
(1, 'WP CAA-1001', 'SAMPLE-FLEET-0001', 'Toyota Aqua - Demo Fleet 1', 'Silver', 2018, 3, 0, 2, 18000.00, 'Ceylinco General Insurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'Aqua', 'Hybrid Petrol', 'Automatic', TRUE, 29200, '1500cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(1, 'WP CAA-1002', 'SAMPLE-FLEET-0002', 'Toyota Vitz - Demo Fleet 2', 'Grey', 2019, 3, 0, 2, 16500.00, 'Allianz Insurance Lanka', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'Vitz', 'Petrol', 'Automatic', TRUE, 33400, '1000cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(1, 'WP CAA-1003', 'SAMPLE-FLEET-0003', 'Suzuki Swift - Demo Fleet 3', 'Black', 2020, 3, 0, 2, 17000.00, 'Union Assurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Suzuki', 'Swift', 'Petrol', 'Automatic', TRUE, 37600, '1200cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(1, 'WP CAA-1004', 'SAMPLE-FLEET-0004', 'Suzuki Wagon R - Demo Fleet 4', 'Blue', 2021, 3, 0, 2, 15000.00, 'Sri Lanka Insurance Corporation', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Suzuki', 'Wagon R', 'Hybrid Petrol', 'Automatic', TRUE, 41800, '660cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(1, 'WP CAA-1005', 'SAMPLE-FLEET-0005', 'Toyota Axio - Demo Fleet 5', 'White', 2022, 3, 0, 2, 19000.00, 'Ceylinco General Insurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'Axio', 'Petrol', 'Automatic', TRUE, 46000, '1500cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(1, 'WP CAA-1006', 'SAMPLE-FLEET-0006', 'Perodua Bezza - Demo Fleet 6', 'Silver', 2023, 3, 0, 2, 15500.00, 'Allianz Insurance Lanka', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Perodua', 'Bezza', 'Petrol', 'Automatic', TRUE, 50200, '1300cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(1, 'WP CAA-1007', 'SAMPLE-FLEET-0007', 'Toyota Prius - Demo Fleet 7', 'Grey', 2024, 3, 0, 2, 20000.00, 'Union Assurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'Prius', 'Hybrid Petrol', 'Automatic', TRUE, 54400, '1800cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(1, 'WP CAA-1008', 'SAMPLE-FLEET-0008', 'Honda Fit - Demo Fleet 8', 'Black', 2025, 3, 0, 2, 17500.00, 'Sri Lanka Insurance Corporation', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Honda', 'Fit', 'Hybrid Petrol', 'Automatic', TRUE, 58600, '1500cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(2, 'WP CAA-1009', 'SAMPLE-FLEET-0009', 'Toyota Axio Hybrid - Demo Fleet 9', 'Blue', 2017, 3, 0, 3, 25000.00, 'Ceylinco General Insurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'Axio Hybrid', 'Hybrid Petrol', 'Automatic', TRUE, 62800, '1500cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(2, 'WP CAA-1010', 'SAMPLE-FLEET-0010', 'Toyota Premio - Demo Fleet 10', 'White', 2018, 3, 0, 3, 30000.00, 'Allianz Insurance Lanka', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'Premio', 'Petrol', 'Automatic', TRUE, 67000, '1800cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(2, 'WP CAA-1011', 'SAMPLE-FLEET-0011', 'Toyota Allion - Demo Fleet 11', 'Silver', 2019, 3, 0, 3, 28000.00, 'Union Assurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'Allion', 'Petrol', 'Automatic', TRUE, 71200, '1800cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(2, 'WP CAA-1012', 'SAMPLE-FLEET-0012', 'Honda Grace - Demo Fleet 12', 'Grey', 2020, 3, 0, 3, 26000.00, 'Sri Lanka Insurance Corporation', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Honda', 'Grace', 'Hybrid Petrol', 'Automatic', TRUE, 75400, '1500cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(2, 'WP CAA-1013', 'SAMPLE-FLEET-0013', 'Toyota Camry - Demo Fleet 13', 'Black', 2021, 3, 0, 3, 35000.00, 'Ceylinco General Insurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'Camry', 'Hybrid Petrol', 'Automatic', TRUE, 79600, '2500cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(2, 'WP CAA-1014', 'SAMPLE-FLEET-0014', 'Nissan Sylphy - Demo Fleet 14', 'Blue', 2022, 3, 0, 3, 27000.00, 'Allianz Insurance Lanka', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Nissan', 'Sylphy', 'Petrol', 'Automatic', TRUE, 83800, '1800cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(2, 'WP CAA-1015', 'SAMPLE-FLEET-0015', 'Honda Civic - Demo Fleet 15', 'White', 2023, 3, 0, 3, 30000.00, 'Union Assurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Honda', 'Civic', 'Petrol', 'Automatic', TRUE, 88000, '1500cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(3, 'WP CAA-1016', 'SAMPLE-FLEET-0016', 'Honda Vezel - Demo Fleet 16', 'Silver', 2024, 4, 0, 3, 30000.00, 'Sri Lanka Insurance Corporation', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Honda', 'Vezel', 'Hybrid Petrol', 'Automatic', TRUE, 92200, '1500cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(3, 'WP CAA-1017', 'SAMPLE-FLEET-0017', 'Toyota Raize - Demo Fleet 17', 'Grey', 2025, 4, 0, 3, 28000.00, 'Ceylinco General Insurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'Raize', 'Petrol', 'Automatic', TRUE, 96400, '1000cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(3, 'WP CAA-1018', 'SAMPLE-FLEET-0018', 'Toyota Rush - Demo Fleet 18', 'Black', 2017, 4, 1, 4, 32000.00, 'Allianz Insurance Lanka', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'Rush', 'Petrol', 'Automatic', TRUE, 100600, '1500cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(3, 'WP CAA-1019', 'SAMPLE-FLEET-0019', 'Mitsubishi Outlander - Demo Fleet 19', 'Blue', 2018, 4, 0, 4, 35000.00, 'Union Assurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Mitsubishi', 'Outlander', 'Petrol', 'Automatic', TRUE, 104800, '2400cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(3, 'WP CAA-1020', 'SAMPLE-FLEET-0020', 'Toyota RAV4 - Demo Fleet 20', 'White', 2019, 4, 0, 4, 38000.00, 'Sri Lanka Insurance Corporation', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'RAV4', 'Hybrid Petrol', 'Automatic', TRUE, 109000, '2500cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(3, 'WP CAA-1021', 'SAMPLE-FLEET-0021', 'Toyota Fortuner - Demo Fleet 21', 'Silver', 2020, 4, 1, 4, 45000.00, 'Ceylinco General Insurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'Fortuner', 'Diesel', 'Automatic', TRUE, 113200, '2800cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(4, 'WP CAA-1022', 'SAMPLE-FLEET-0022', 'Toyota Land Cruiser Prado Safari - Demo Fleet 22', 'Grey', 2021, 6, 0, 2, 45000.00, 'Allianz Insurance Lanka', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'Land Cruiser Prado Safari', 'Diesel', 'Automatic', FALSE, 117400, '2800cc', '4WD, Safari Seating, First Aid Kit'),
(4, 'WP CAA-1023', 'SAMPLE-FLEET-0023', 'Toyota Hilux Safari Jeep - Demo Fleet 23', 'Black', 2022, 6, 0, 2, 42000.00, 'Union Assurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'Hilux Safari Jeep', 'Diesel', 'Manual', FALSE, 121600, '2800cc', '4WD, Safari Seating, First Aid Kit'),
(4, 'WP CAA-1024', 'SAMPLE-FLEET-0024', 'Mahindra Bolero Safari Jeep - Demo Fleet 24', 'Blue', 2023, 6, 1, 2, 35000.00, 'Sri Lanka Insurance Corporation', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Mahindra', 'Bolero Safari Jeep', 'Diesel', 'Manual', FALSE, 125800, '2500cc', '4WD, Safari Seating, First Aid Kit'),
(4, 'WP CAA-1025', 'SAMPLE-FLEET-0025', 'Nissan Patrol Safari Jeep - Demo Fleet 25', 'White', 2024, 6, 0, 2, 50000.00, 'Ceylinco General Insurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Nissan', 'Patrol Safari Jeep', 'Petrol', 'Automatic', FALSE, 130000, '4000cc', '4WD, Safari Seating, First Aid Kit'),
(4, 'WP CAA-1026', 'SAMPLE-FLEET-0026', 'Toyota Land Cruiser Safari Jeep - Demo Fleet 26', 'Silver', 2025, 6, 0, 2, 55000.00, 'Allianz Insurance Lanka', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'Land Cruiser Safari Jeep', 'Diesel', 'Automatic', FALSE, 134200, '3000cc', '4WD, Safari Seating, First Aid Kit'),
(5, 'WP CAA-1027', 'SAMPLE-FLEET-0027', 'Toyota HiAce KDH - Demo Fleet 27', 'Grey', 2017, 8, 1, 8, 32000.00, 'Union Assurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'HiAce KDH', 'Diesel', 'Automatic', TRUE, 138400, '3000cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(5, 'WP CAA-1028', 'SAMPLE-FLEET-0028', 'Toyota HiAce Commuter - Demo Fleet 28', 'Black', 2018, 12, 0, 10, 35000.00, 'Sri Lanka Insurance Corporation', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'HiAce Commuter', 'Diesel', 'Manual', TRUE, 142600, '2500cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(5, 'WP CAA-1029', 'SAMPLE-FLEET-0029', 'Nissan Caravan - Demo Fleet 29', 'Blue', 2019, 10, 0, 8, 30000.00, 'Ceylinco General Insurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Nissan', 'Caravan', 'Diesel', 'Automatic', TRUE, 146800, '2500cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(5, 'WP CAA-1030', 'SAMPLE-FLEET-0030', 'Mitsubishi Rosa Van - Demo Fleet 30', 'White', 2020, 12, 1, 10, 38000.00, 'Allianz Insurance Lanka', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Mitsubishi', 'Rosa Van', 'Diesel', 'Manual', TRUE, 151000, '4000cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(5, 'WP CAA-1031', 'SAMPLE-FLEET-0031', 'Toyota HiAce Super GL - Demo Fleet 31', 'Silver', 2021, 8, 0, 7, 36000.00, 'Union Assurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'HiAce Super GL', 'Diesel', 'Automatic', TRUE, 155200, '2800cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(5, 'WP CAA-1032', 'SAMPLE-FLEET-0032', 'Toyota HiAce KDH High Roof - Demo Fleet 32', 'Grey', 2022, 9, 0, 8, 34000.00, 'Sri Lanka Insurance Corporation', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'HiAce KDH High Roof', 'Diesel', 'Automatic', TRUE, 159400, '3000cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(5, 'WP CAA-1033', 'SAMPLE-FLEET-0033', 'Nissan Urvan - Demo Fleet 33', 'Black', 2023, 10, 1, 8, 31000.00, 'Ceylinco General Insurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Nissan', 'Urvan', 'Diesel', 'Manual', TRUE, 163600, '2500cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(5, 'WP CAA-1034', 'SAMPLE-FLEET-0034', 'Mitsubishi L300 - Demo Fleet 34', 'Blue', 2024, 8, 0, 6, 28000.00, 'Allianz Insurance Lanka', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Mitsubishi', 'L300', 'Diesel', 'Manual', TRUE, 167800, '2500cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(6, 'WP CAA-1035', 'SAMPLE-FLEET-0035', 'Toyota Coaster - Demo Fleet 35', 'White', 2025, 22, 0, 20, 55000.00, 'Union Assurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Toyota', 'Coaster', 'Diesel', 'Manual', TRUE, 172000, '4000cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(6, 'WP CAA-1036', 'SAMPLE-FLEET-0036', 'Mitsubishi Rosa Mini Bus - Demo Fleet 36', 'Silver', 2017, 25, 1, 22, 60000.00, 'Sri Lanka Insurance Corporation', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Mitsubishi', 'Rosa Mini Bus', 'Diesel', 'Manual', TRUE, 176200, '4000cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(6, 'WP CAA-1037', 'SAMPLE-FLEET-0037', 'Isuzu Journey Mini Bus - Demo Fleet 37', 'Grey', 2018, 25, 0, 22, 58000.00, 'Ceylinco General Insurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Isuzu', 'Journey Mini Bus', 'Diesel', 'Manual', TRUE, 180400, '5000cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(6, 'WP CAA-1038', 'SAMPLE-FLEET-0038', 'Ashok Leyland MiDi Bus - Demo Fleet 38', 'Black', 2019, 25, 0, 22, 52000.00, 'Allianz Insurance Lanka', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Ashok Leyland', 'MiDi Bus', 'Diesel', 'Manual', TRUE, 184600, '4000cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(7, 'WP CAA-1039', 'SAMPLE-FLEET-0039', 'Isuzu Luxury Coach - Demo Fleet 39', 'Blue', 2020, 40, 1, 35, 85000.00, 'Union Assurance', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Isuzu', 'Luxury Coach', 'Diesel', 'Manual', TRUE, 188800, '7500cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker'),
(7, 'WP CAA-1040', 'SAMPLE-FLEET-0040', 'Ashok Leyland Viking Coach - Demo Fleet 40', 'White', 2021, 45, 0, 40, 90000.00, 'Sri Lanka Insurance Corporation', '2025-01-01'::DATE, '2027-12-31'::DATE, 'AVAILABLE'::vehicle_status_type, 'Ashok Leyland', 'Viking Coach', 'Diesel', 'Manual', TRUE, 193000, '6000cc', 'Air Conditioning, Seat Belts, First Aid Kit, GPS Tracker');

-- =========================================================
-- 3. PLACES (114 curated Sri Lankan destinations)
-- Coordinates are approximate destination/landmark coordinates, not survey-grade GPS.
-- Image URLs are NULL intentionally: do not seed fabricated or unverified image links.
-- =========================================================
INSERT INTO place (place_name, image_url, description, latitude, longitude)
VALUES
('Sigiriya Rock Fortress', NULL, 'Ancient rock citadel and UNESCO World Heritage Site in the Cultural Triangle.', 7.9570000, 80.7603000),
('Pidurangala Rock', NULL, 'Rock outcrop north of Sigiriya with views of the surrounding plains.', 7.9698000, 80.7603000),
('Dambulla Cave Temple', NULL, 'Historic cave temple complex and UNESCO World Heritage Site.', 7.8567000, 80.6492000),
('Polonnaruwa Ancient City', NULL, 'Archaeological remains of a medieval Sri Lankan capital.', 7.9403000, 81.0188000),
('Gal Vihara', NULL, 'Rock-cut Buddha statues within the Polonnaruwa archaeological site.', 7.9970000, 81.0030000),
('Anuradhapura Sacred City', NULL, 'Ancient capital with major Buddhist monuments and archaeological remains.', 8.3114000, 80.4037000),
('Sri Maha Bodhi', NULL, 'Sacred Bodhi tree shrine in Anuradhapura.', 8.3509000, 80.3964000),
('Ruwanwelisaya', NULL, 'Major ancient Buddhist stupa in Anuradhapura.', 8.3508000, 80.3960000),
('Mihintale', NULL, 'Historic Buddhist pilgrimage site near Anuradhapura.', 8.3505000, 80.5110000),
('Temple of the Sacred Tooth Relic', NULL, 'Historic Buddhist temple in Kandy.', 7.2936000, 80.6413000),
('Kandy Lake', NULL, 'Historic lake beside the Temple of the Tooth.', 7.2925000, 80.6415000),
('Royal Botanic Gardens Peradeniya', NULL, 'Botanical gardens near Kandy with extensive tropical plant collections.', 7.2723000, 80.5955000),
('Bahirawakanda Buddha Statue', NULL, 'Large Buddha statue overlooking Kandy.', 7.2895000, 80.6270000),
('Embekka Devalaya', NULL, 'Historic shrine known for carved timber pillars.', 7.2470000, 80.5780000),
('Galle Fort', NULL, 'UNESCO-listed fortified historic town on the southern coast.', 6.0260000, 80.2170000),
('Galle Lighthouse', NULL, 'Lighthouse within the Galle Fort precinct.', 6.0258000, 80.2180000),
('Unawatuna Beach', NULL, 'Popular sandy beach near Galle.', 6.0108000, 80.2490000),
('Jungle Beach Unawatuna', NULL, 'Small coastal cove near Unawatuna.', 6.0065000, 80.2465000),
('Hikkaduwa Beach', NULL, 'Coastal destination known for surfing and marine activities.', 6.1395000, 80.1010000),
('Hikkaduwa National Park', NULL, 'Marine protected area with coral reef habitats.', 6.1360000, 80.1030000),
('Mirissa Beach', NULL, 'Southern coastal beach and seasonal whale-watching departure point.', 5.9467000, 80.4590000),
('Coconut Tree Hill Mirissa', NULL, 'Coastal viewpoint in Mirissa known for its palm trees.', 5.9448000, 80.4608000),
('Weligama Bay', NULL, 'Bay popular for beginner surfing.', 5.9740000, 80.4290000),
('Kabalana Beach', NULL, 'Ahangama-area beach known for surf breaks.', 5.9748000, 80.3650000),
('Hiriketiya Beach', NULL, 'Small horseshoe-shaped bay near Dikwella.', 5.9650000, 80.7040000),
('Tangalle Beach', NULL, 'Southern coastal area with long beaches and rocky coves.', 6.0240000, 80.7950000),
('Bentota Beach', NULL, 'West-coast beach destination with river activities.', 6.4210000, 79.9950000),
('Madu River', NULL, 'Wetland estuary near Balapitiya known for mangroves.', 6.2760000, 80.0350000),
('Kosgoda Beach', NULL, 'Coastal area associated with sea turtle conservation.', 6.3330000, 80.0300000),
('Ella', NULL, 'Hill-country town known for mountain scenery and hiking.', 6.8667000, 81.0466000),
('Nine Arch Bridge', NULL, 'Historic railway viaduct near Ella.', 6.8768000, 81.0608000),
('Little Adam''s Peak', NULL, 'Popular hiking summit near Ella.', 6.8715000, 81.0580000),
('Ella Rock', NULL, 'Hiking viewpoint overlooking Ella.', 6.8670000, 81.0470000),
('Ravana Falls', NULL, 'Waterfall beside the Ella-Wellawaya road.', 6.8390000, 81.0580000),
('Diyaluma Falls', NULL, 'High waterfall near Koslanda.', 6.7330000, 81.0320000),
('Horton Plains National Park', NULL, 'High-altitude protected plateau with cloud forest and grassland.', 6.8020000, 80.8020000),
('World''s End', NULL, 'Escarpment viewpoint within Horton Plains.', 6.7960000, 80.7980000),
('Baker''s Falls', NULL, 'Waterfall on the Horton Plains walking trail.', 6.8080000, 80.8070000),
('Gregory Lake', NULL, 'Lake and recreation area in Nuwara Eliya.', 6.9690000, 80.7820000),
('Hakgala Botanical Garden', NULL, 'Botanical garden near Nuwara Eliya.', 6.9230000, 80.8190000),
('Lipton''s Seat', NULL, 'Viewpoint above the Dambatenne tea-growing area.', 6.7700000, 81.0000000),
('Adisham Bungalow', NULL, 'Historic country house and monastery near Haputale.', 6.7680000, 80.9580000),
('Adam''s Peak (Sri Pada)', NULL, 'Sacred mountain and pilgrimage destination in the central highlands.', 6.8096000, 80.4994000),
('Knuckles Conservation Forest', NULL, 'Mountain forest reserve known for biodiversity and trekking.', 7.4500000, 80.8000000),
('Riverston', NULL, 'Scenic highland area in the Knuckles region.', 7.5200000, 80.7400000),
('Meemure', NULL, 'Remote village near the Knuckles mountain range.', 7.4330000, 80.8500000),
('Sinharaja Forest Reserve', NULL, 'UNESCO-listed tropical rainforest reserve.', 6.4050000, 80.5000000),
('Kitulgala', NULL, 'River-side town known for white-water rafting.', 6.9890000, 80.4180000),
('Bopath Ella', NULL, 'Waterfall near Kuruwita in the Ratnapura District.', 6.7000000, 80.3850000),
('Bambarakanda Falls', NULL, 'Sri Lanka''s tallest waterfall near Kalupahana.', 6.7720000, 80.8300000),
('Udawalawe National Park', NULL, 'National park known for Asian elephant sightings.', 6.4750000, 80.8880000),
('Yala National Park', NULL, 'National park in the southeast known for wildlife.', 6.3720000, 81.5180000),
('Bundala National Park', NULL, 'Coastal wetland national park important for migratory birds.', 6.1780000, 81.2050000),
('Minneriya National Park', NULL, 'National park known for seasonal elephant gatherings.', 8.0380000, 80.8850000),
('Kaudulla National Park', NULL, 'Dry-zone national park with elephant herds and reservoir habitats.', 8.1350000, 80.8850000),
('Wilpattu National Park', NULL, 'Large national park in the northwest known for villus and wildlife.', 8.4500000, 80.0000000),
('Kumana National Park', NULL, 'Eastern national park and important bird habitat.', 6.6000000, 81.7000000),
('Gal Oya National Park', NULL, 'Protected area around Senanayake Samudraya.', 7.2500000, 81.3500000),
('Arugam Bay', NULL, 'East-coast surfing destination near Pottuvil.', 6.8400000, 81.8360000),
('Pasikudah Beach', NULL, 'Shallow bay on the east coast known for calm-water recreation.', 7.9260000, 81.5620000),
('Nilaveli Beach', NULL, 'Beach north of Trincomalee, close to Pigeon Island.', 8.6930000, 81.1900000),
('Pigeon Island National Park', NULL, 'Marine national park off Nilaveli with coral reef habitats.', 8.7200000, 81.2050000),
('Koneswaram Temple', NULL, 'Hindu temple on Swami Rock overlooking Trincomalee harbour.', 8.5710000, 81.2390000),
('Fort Frederick', NULL, 'Historic fortification at the Trincomalee peninsula.', 8.5720000, 81.2400000),
('Jaffna Fort', NULL, 'Historic Dutch-era fort in Jaffna town.', 9.6610000, 80.0100000),
('Nallur Kandaswamy Kovil', NULL, 'Important Hindu temple in Jaffna.', 9.6750000, 80.0250000),
('Casuarina Beach', NULL, 'Beach on Karainagar Island in the Jaffna District.', 9.7600000, 79.8870000),
('Delft Island', NULL, 'Island in the Palk Strait known for wild ponies and historic remains.', 9.5200000, 79.6800000),
('Mannar Baobab Tree', NULL, 'Notable baobab tree on Mannar Island.', 8.9810000, 79.9040000),
('Kalpitiya Lagoon', NULL, 'Coastal lagoon area known for kite surfing and seasonal dolphin watching.', 8.2300000, 79.7600000),
('Negombo Lagoon', NULL, 'Large coastal lagoon with fishing and mangrove habitats.', 7.1900000, 79.8400000),
('Negombo Dutch Canal', NULL, 'Historic canal passing through Negombo and the western coastal region.', 7.2100000, 79.8400000),
('Colombo National Museum', NULL, 'National museum documenting Sri Lankan history and culture.', 6.9100000, 79.8600000),
('Gangaramaya Temple', NULL, 'Buddhist temple complex in Colombo near Beira Lake.', 6.9167000, 79.8563000),
('Independence Memorial Hall', NULL, 'National monument in Colombo commemorating independence.', 6.9065000, 79.8680000),
('Galle Face Green', NULL, 'Seafront urban park in central Colombo.', 6.9270000, 79.8440000),
('Jami Ul-Alfar Mosque', NULL, 'Historic red-and-white mosque in Pettah, Colombo.', 6.9350000, 79.8500000),
('Dambatenne Tea Factory', NULL, 'Tea factory near Haputale associated with the Lipton tea-growing area.', 6.7700000, 80.9700000),
('Nuwara Eliya Post Office', NULL, 'Historic colonial-era post office in Nuwara Eliya.', 6.9700000, 80.7680000),
('Ambuluwawa Tower', NULL, 'Observation tower on Ambuluwawa mountain near Gampola.', 7.1450000, 80.5360000),
('Pinnawala Elephant Orphanage', NULL, 'Elephant care facility in Pinnawala; check current visitor and welfare guidance.', 7.3000000, 80.3890000),
('Mulkirigala Raja Maha Viharaya', NULL, 'Ancient rock temple with cave shrines near Tangalle.', 6.0840000, 80.7370000),
('Hummanaya Blow Hole', NULL, 'Natural blow hole near Kudawella on the southern coast.', 5.9770000, 80.7500000),
('Kataragama Sacred City', NULL, 'Multi-faith pilgrimage town in the southeast.', 6.4140000, 81.3330000),
('Dondra Head Lighthouse', NULL, 'Lighthouse near the southernmost point of mainland Sri Lanka.', 5.9330000, 80.5940000),
('Matara Star Fort', NULL, 'Historic star-shaped fort in Matara.', 5.9480000, 80.5350000),
('Jaffna Public Library', NULL, 'Landmark public library in Jaffna town.', 9.6650000, 80.0100000),
('Ritigala Archaeological Site', NULL, 'Ancient monastic complex within a forest reserve.', 8.1050000, 80.6650000),
('Avukana Buddha Statue', NULL, 'Large standing Buddha statue near Kekirawa.', 8.0110000, 80.5130000),
('Yapahuwa Rock Fortress', NULL, 'Medieval rock fortress known for its ornate stone staircase.', 7.8180000, 80.3060000),
('Medirigiriya Vatadage', NULL, 'Ancient circular relic house in the Polonnaruwa District.', 8.0380000, 80.9850000),
('Aluvihare Rock Temple', NULL, 'Historic Buddhist cave temple near Matale.', 7.5000000, 80.6020000),
('Nalanda Gedige', NULL, 'Medieval stone shrine near Matale.', 7.6730000, 80.6520000),
('Koggala Lake', NULL, 'Coastal lake near Galle with islands and mangrove habitats.', 5.9980000, 80.3300000),
('Martin Wickramasinghe Folk Museum', NULL, 'Museum in Koggala dedicated to Sri Lankan folk culture and literature.', 5.9970000, 80.3300000),
('Budduruwagala', NULL, 'Rock-carved Buddhist figures near Wellawaya.', 6.7370000, 81.0960000),
('Dunhinda Falls', NULL, 'Waterfall near Badulla reached by a forest footpath.', 7.0050000, 81.0570000),
('Sembuwatta Lake', NULL, 'Lake in the Elkaduwa area surrounded by tea estates.', 7.5480000, 80.6740000),
('Hanthana Mountain Range', NULL, 'Mountain range southwest of Kandy with hiking routes.', 7.2670000, 80.6200000),
('Udawattakele Forest Reserve', NULL, 'Forest reserve above Kandy with walking trails and birdlife.', 7.2990000, 80.6420000),
('Bolgoda Lake', NULL, 'Large freshwater lake system south of Colombo.', 6.7600000, 79.9200000),
('Kalutara Bodhiya', NULL, 'Buddhist shrine near the Kalu Ganga bridge in Kalutara.', 6.5850000, 79.9600000),
('Richmond Castle', NULL, 'Historic mansion near Kalutara with early twentieth-century architecture.', 6.5850000, 79.9600000),
('Beruwala Lighthouse', NULL, 'Lighthouse on Barberyn Island near Beruwala.', 6.4630000, 79.9820000),
('Belilena Cave', NULL, 'Prehistoric cave site near Kitulgala.', 6.9890000, 80.4140000),
('Pahiyangala (Fa-Hien Cave)', NULL, 'Large prehistoric cave site near Bulathsinhala.', 6.6500000, 80.1900000),
('Maduru Oya National Park', NULL, 'Dry-zone national park with reservoir landscapes and wildlife.', 7.7500000, 81.1500000),
('Somawathiya Stupa', NULL, 'Buddhist stupa in the Somawathiya National Park area.', 8.1000000, 81.1800000),
('Lankapatuna Samudragiri Viharaya', NULL, 'Historic Buddhist temple site near the eastern coast.', 8.4700000, 81.2800000),
('Kudumbigala Monastery', NULL, 'Ancient forest monastery near Panama and Kumana.', 6.7000000, 81.7200000),
('Okanda Murugan Temple', NULL, 'Hindu shrine on the southeastern coast near Kumana.', 6.6500000, 81.7300000),
('Magul Maha Viharaya', NULL, 'Archaeological Buddhist site near Pottuvil.', 6.8500000, 81.7500000),
('Maligawila Buddha Statue', NULL, 'Large standing Buddha statue near Okkampitiya.', 6.8750000, 81.3500000),
('Ridiyagama Safari Park', NULL, 'Open-range safari park near Hambantota.', 6.2000000, 81.0500000);


-- =========================================================
-- 4. ACTIVITIES (114 practical Sri Lankan activities)
-- Phone is NULL because no verified operator phone number is supplied.
-- Descriptions avoid claiming SLTDA certification for unnamed providers.
-- =========================================================
INSERT INTO activity (activity_name, phone, description)
VALUES
('Guided visit to Sigiriya Rock Fortress', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Pidurangala Rock hike and viewpoint visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Guided visit to Dambulla Cave Temple', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Polonnaruwa archaeological city cycling tour', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Guided visit to Gal Vihara', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Anuradhapura ancient city heritage tour', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Visit to Sri Maha Bodhi shrine', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Visit to Ruwanwelisaya stupa', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Mihintale heritage and pilgrimage walk', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Guided visit to the Temple of the Sacred Tooth Relic', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Kandy Lake heritage walk', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Peradeniya Royal Botanic Gardens visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Visit to Bahirawakanda Buddha Statue', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Visit to Embekka Devalaya timber carvings', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Galle Fort walking tour', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Galle Lighthouse and rampart walk', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Unawatuna beach visit and swimming', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Walk to Jungle Beach, Unawatuna', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Hikkaduwa beach and surf lesson', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Snorkelling at Hikkaduwa marine area (conditions permitting)', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Mirissa coastal visit and seasonal whale-watching excursion', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Coconut Tree Hill viewpoint visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Weligama beginner surf lesson', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Ahangama surf session at Kabalana', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Hiriketiya beach and surf session', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Tangalle coastal and beach visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Bentota beach and water-sports activity', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Guided Madu River mangrove boat excursion', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Kosgoda turtle conservation centre visit (operator permitting)', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Ella town and tea-country walk', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Visit to Nine Arch Bridge', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Little Adam''s Peak hike', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Ella Rock guided hike', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Ravana Falls viewpoint visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Diyaluma Falls hike with local guide', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Horton Plains National Park nature trail', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('World''s End viewpoint hike', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Baker''s Falls trail walk', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Gregory Lake visit and lakeside recreation', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Hakgala Botanical Garden visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Lipton''s Seat sunrise viewpoint excursion', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Adisham Bungalow visit (opening days permitting)', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Sri Pada pilgrimage hike (seasonal)', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Knuckles Conservation Forest guided trek', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Riverston and Pitawala Pathana viewpoint excursion', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Meemure village and countryside visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Sinharaja rainforest guided nature walk', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Kitulgala white-water rafting with licensed operator', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Bopath Ella waterfall visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Bambarakanda Falls nature walk', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Udawalawe National Park jeep safari with licensed operator', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Yala National Park jeep safari with licensed operator', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Bundala National Park birdwatching safari', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Minneriya National Park wildlife safari', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Kaudulla National Park wildlife safari', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Wilpattu National Park jeep safari', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Kumana National Park birdwatching safari', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Gal Oya reservoir boat safari with licensed operator', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Arugam Bay surf lesson', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Pasikudah beach and shallow-water recreation', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Nilaveli beach visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Pigeon Island marine park snorkelling (permit and sea conditions permitting)', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Koneswaram Temple heritage visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Fort Frederick walking visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Jaffna Fort heritage walk', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Nallur Kandaswamy Kovil visit (respecting worship times)', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Casuarina Beach visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Delft Island guided island excursion', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Mannar baobab tree visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Kalpitiya lagoon kite-surfing lesson with qualified operator', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Negombo Lagoon guided boat excursion', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Negombo Dutch Canal heritage boat trip', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Colombo National Museum visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Gangaramaya Temple and Beira Lake visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Independence Memorial Hall visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Galle Face Green evening walk', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Jami Ul-Alfar Mosque exterior and Pettah heritage walk', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Dambatenne Tea Factory visit (advance confirmation required)', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Nuwara Eliya town heritage walk', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Ambuluwawa Tower visit (weather and access permitting)', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Pinnawala Elephant Orphanage visit (review current welfare and visitor policy)', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Mulkirigala rock temple visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Hummanaya Blow Hole viewpoint visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Kataragama sacred sites visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Dondra Head Lighthouse area visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Matara Star Fort heritage walk', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Jaffna Public Library visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Ritigala archaeological and nature trail (access rules permitting)', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Avukana Buddha Statue visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Yapahuwa Rock Fortress climb', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Medirigiriya Vatadage archaeological visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Aluvihare Rock Temple visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Nalanda Gedige heritage visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Koggala Lake guided boat excursion', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Martin Wickramasinghe Folk Museum visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Budduruwagala rock sculptures visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Dunhinda Falls guided nature walk', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Sembuwatta Lake visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Hanthana mountain hiking excursion', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Udawattakele Forest Reserve nature walk', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Bolgoda Lake boat excursion', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Kalutara Bodhiya visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Richmond Castle heritage visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Beruwala Barberyn Lighthouse boat visit (access permitting)', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Belilena Cave guided archaeological visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Pahiyangala cave site visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Maduru Oya National Park safari', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Somawathiya Stupa pilgrimage visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Lankapatuna Samudragiri Viharaya visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Kudumbigala monastery and nature trail', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Okanda Murugan Temple visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Magul Maha Viharaya archaeological visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Maligawila Buddha Statue visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.'),
('Ridiyagama Safari Park visit', NULL, 'Suggested visitor activity in Sri Lanka. Availability, permits, operator qualifications, weather and seasonal conditions should be confirmed before booking.');

-- =========================================================
-- 5. PLACE-ACTIVITY JUNCTION
-- The activity list follows the destination list in the same order.
-- =========================================================
INSERT INTO place_activity (place_id, activity_id)
SELECT p.place_id, a.activity_id
FROM place p
JOIN activity a ON a.activity_id = p.place_id
WHERE p.place_id <= (SELECT COUNT(*) FROM activity);


-- =========================================================
-- 6. PACKAGES (20 Sri Lanka itineraries; sample catalogue data)
-- Weather is deliberately not represented as a fixed forecast.
-- Images are NULL until verified image assets are supplied.
-- =========================================================
INSERT INTO package (title, type, days, description, weather, image_url, availability_status)
VALUES
('Cultural Triangle Essentials', 'CULTURAL HERITAGE', '7 DAYS', 'A seven-day route covering Sigiriya, Dambulla, Polonnaruwa and Kandy, with time for major archaeological and cultural sites.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE'),
('Ancient Capitals and Sacred Cities', 'CULTURAL HERITAGE', '14 DAYS', 'A two-week heritage journey through Anuradhapura, Mihintale, Dambulla, Sigiriya, Polonnaruwa and Kandy.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE'),
('Heritage, Temples and the Southern Forts', 'CULTURAL HERITAGE', '21 DAYS', 'A longer cultural circuit linking the Cultural Triangle, Kandy, Colombo and Galle Fort.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE'),
('Sri Lankan Heritage Island Circuit', 'CULTURAL HERITAGE', '28 DAYS', 'A four-week island journey combining the ancient cities, Kandy, Jaffna, Colombo and the southern heritage coast.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE'),
('Ella and Knuckles Hiking Escape', 'ADVENTURE', '7 DAYS', 'A week of guided hikes around Ella, Little Adam''s Peak, Nine Arch Bridge and selected Knuckles-area trails.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE'),
('Rainforest, Rivers and Mountain Trails', 'ADVENTURE', '14 DAYS', 'An active itinerary combining Kitulgala rafting, Sinharaja rainforest walks, Ella and central highland trails.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE'),
('Highland Trekking and Waterfall Trail', 'ADVENTURE', '21 DAYS', 'A three-week route through Adam''s Peak, Horton Plains, Ella, Diyaluma and the Knuckles region.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE'),
('Sri Lanka Active Nature Expedition', 'ADVENTURE', '28 DAYS', 'A four-week nature-focused journey combining hiking, rafting, rainforest visits and selected coastal activities.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE'),
('Southern Coast Relaxation', 'WELLNESS & AYURVEDA', '7 DAYS', 'A relaxed coastal stay around Bentota, Galle and Unawatuna, with optional yoga and visits to established wellness centres.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE'),
('Ayurveda and Coastal Retreat', 'WELLNESS & AYURVEDA', '14 DAYS', 'A two-week slow-travel itinerary on the southern and western coast, with optional treatments arranged through qualified local providers.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE'),
('Mindful Island Stay', 'WELLNESS & AYURVEDA', '21 DAYS', 'A three-week relaxed itinerary combining coastal stays, botanical gardens, gentle walks and optional wellness sessions.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE'),
('Extended Wellness and Nature Break', 'WELLNESS & AYURVEDA', '28 DAYS', 'A four-week flexible stay combining the southern coast, hill-country scenery and optional wellness activities.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE'),
('Southern Beaches and Heritage', 'BEACH SIDE', '7 DAYS', 'A coastal route covering Bentota, Galle, Unawatuna, Weligama and Mirissa.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE'),
('Surf Coast and East Coast Beaches', 'BEACH SIDE', '14 DAYS', 'A two-week beach itinerary linking Weligama, Ahangama, Mirissa and seasonal east-coast stops such as Arugam Bay.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE'),
('Island Coastline Explorer', 'BEACH SIDE', '21 DAYS', 'A three-week coastal journey combining southern beaches with Trincomalee, Nilaveli, Pasikudah and the east coast.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE'),
('Nuwara Eliya and Ella Hill Country', 'HILL COUNTRY', '7 DAYS', 'A week among tea estates, waterfalls and highland towns, including Nuwara Eliya, Haputale and Ella.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE'),
('Central Highlands Scenic Journey', 'HILL COUNTRY', '14 DAYS', 'A two-week route through Kandy, Nuwara Eliya, Horton Plains, Haputale and Ella.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE'),
('Udawalawe and Yala Wildlife Circuit', 'SAFARI', '7 DAYS', 'A wildlife-focused route with guided jeep safaris in Udawalawe and Yala, subject to park rules and availability.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE'),
('National Parks and Birdlife Expedition', 'SAFARI', '14 DAYS', 'A two-week nature itinerary featuring Wilpattu, Minneriya, Kaudulla, Bundala and Kumana where seasonal conditions allow.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE'),
('Sri Lanka Wildlife and Nature Journey', 'SAFARI', '21 DAYS', 'A three-week route combining selected national parks, wetland habitats and the Gal Oya region, with licensed local safari operators.', '{"note":"Sri Lanka weather varies by region and season; check a current forecast before travel."}', NULL, 'AVAILABLE');

-- =========================================================
-- 7. PACKAGE-PLACE ROUTING
-- =========================================================
-- Seed indicative destination stops for each package. These are demo associations, not a turn-by-turn route.
INSERT INTO package_place (package_id, place_id, day_number, latitude, longitude)
SELECT 
    sub.package_id,
    sub.place_id,
    sub.day_number,
    p.latitude,
    p.longitude
FROM (
    SELECT 
        pkg.package_id,
        CASE
            WHEN pkg.package_id BETWEEN 1 AND 4 THEN 1 + (((pkg.package_id * 3 + d - 1) % 15))
            WHEN pkg.package_id BETWEEN 5 AND 8 THEN 30 + (((pkg.package_id * 2 + d - 1) % 19))
            WHEN pkg.package_id BETWEEN 9 AND 12 THEN 16 + (((pkg.package_id * 2 + d - 1) % 14))
            WHEN pkg.package_id BETWEEN 13 AND 15 THEN 16 + (((pkg.package_id * 3 + d - 1) % 14))
            WHEN pkg.package_id BETWEEN 16 AND 17 THEN 30 + (((pkg.package_id * 3 + d - 1) % 19))
            ELSE 49 + (((pkg.package_id * 2 + d - 1) % 12))
        END AS place_id,
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
    ) days_gen
) sub
JOIN place p ON p.place_id = sub.place_id;

-- =========================================================
-- 8. USERS (1,500 synthetic international customer profiles + 10 demo admins)
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
-- 9. BOOKINGS (2,200 synthetic sample bookings)
-- =========================================================
-- Sample historical/future bookings distributed across 2024-01-01 to 2026-10-01.
INSERT INTO booking (
    user_id, customer_name, contact_platform, contact_number, tour_type, 
    category_id, vehicle_id, start_date, end_date, pickup_time, 
    start_location, end_location, pickup_lat, pickup_lng, dropoff_lat, dropoff_lng,
    total_days, days_required, 
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
    (ARRAY[7.1807560, 6.2917780, 6.9344440, 7.2341670, 6.0305560])[1 + (i % 5)]::numeric(10, 7),
    (ARRAY[79.8841450, 81.1241670, 79.8427780, 79.8430560, 80.2172220])[1 + (i % 5)]::numeric(10, 7),
    (ARRAY[7.1807560, 6.9450000, 7.2280000, 5.9482600, 6.9180000])[1 + (i % 5)]::numeric(10, 7),
    (ARRAY[79.8841450, 79.8520000, 79.8410000, 80.4578100, 79.8550000])[1 + (i % 5)]::numeric(10, 7),
    b_days,
    b_days,
    1 + (i % 3),
    1 + (i % 4),
    CASE WHEN i % 4 = 0 THEN 1 ELSE 0 END,
    1 + (i % 4),
    CASE WHEN i % 5 = 0 THEN 1 WHEN i % 9 = 0 THEN 2 ELSE 0 END,
    CASE WHEN i % 5 = 0 THEN '7' WHEN i % 9 = 0 THEN '5, 10' ELSE NULL END,
    b_price,
    CASE WHEN i % 7 = 0 THEN 5000.00 ELSE 0.00 END,
    'Sample request: confirm arrival time and preferred language with the customer.',
    'Sample customer preference: cultural attractions, coastal stops and hill-country scenery.',
    'Sample admin note: confirm vehicle suitability and availability before approval.',
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
        1 + (i % 40) AS b_veh_id,
        CASE
            WHEN (1 + (i % 40)) <= 8 THEN 1
            WHEN (1 + (i % 40)) <= 15 THEN 2
            WHEN (1 + (i % 40)) <= 21 THEN 3
            WHEN (1 + (i % 40)) <= 26 THEN 4
            WHEN (1 + (i % 40)) <= 34 THEN 5
            WHEN (1 + (i % 40)) <= 38 THEN 6
            ELSE 7
        END AS b_cat_id,
        CASE 
            -- Chronological progression based on end date vs simulation boundary (2026-10-01)
            WHEN vars.b_start_raw + vars.b_days < '2026-09-01'::DATE THEN
                (ARRAY['COMPLETED', 'CLOSED', 'COMPLETED', 'CLOSED', 'CANCELLED'])[1 + (i % 5)]::booking_status_type
            WHEN vars.b_start_raw <= '2026-10-01'::DATE AND vars.b_start_raw + vars.b_days >= '2026-10-01'::DATE THEN 
                'TOUR_STARTED'::booking_status_type
            ELSE 
                (ARRAY['CONFIRMED', 'QUOTED', 'ACCEPTED', 'PENDING'])[1 + (i % 4)]::booking_status_type
        END AS b_status,
        (vars.b_days * (
            SELECT v.price_per_day
            FROM vehicle v
            WHERE v.vehicle_id = 1 + (i % 40)
        ))::NUMERIC(10,2) AS b_price
) AS derived;

-- =========================================================
-- 10. BOOKING-PACKAGE JUNCTION
-- =========================================================
INSERT INTO booking_package (booking_id, package_id)
SELECT
    b.booking_id,
    matched.package_id
FROM booking b
CROSS JOIN LATERAL (
    SELECT p.package_id
    FROM package p
    WHERE p.days::TEXT = (b.total_days::TEXT || ' DAYS')
    ORDER BY p.package_id
    OFFSET ((b.booking_id - 1) % (
        SELECT COUNT(*) FROM package p2
        WHERE p2.days::TEXT = (b.total_days::TEXT || ' DAYS')
    ))
    LIMIT 1
) matched
WHERE b.tour_type = 'PACKAGE';

-- =========================================================
-- 11. PAYMENTS (Deposit, Final Settlements & Pending Slips)
-- =========================================================
-- 1st Installment (Advance Deposit of 30% upon confirmation)
INSERT INTO payment (
    booking_id, installment, amount, payment_method, received_date, 
    recorded_by, status, slip_url, notes, created_at
)
SELECT 
    b.booking_id,
    'ADVANCE',
    ROUND((b.quoted_price * 0.30)::NUMERIC, 2),
    (ARRAY['BANK_TRANSFER', 'CASH', 'BANK_TRANSFER'])[1 + (b.booking_id % 3)]::payment_method_type,
    b.confirmed_at::DATE,
    1 + (b.booking_id % 10), -- Recorded by one of the 10 Admin users
    'APPROVED',
    NULL,
    'Sample advance payment of 30% recorded after booking confirmation; demo data only.',
    b.confirmed_at + interval '1 hour'
FROM booking b
WHERE b.booking_status IN ('CONFIRMED', 'TOUR_STARTED', 'COMPLETED', 'CLOSED');

-- 2nd Installment (Final Balance of 70% paid on arrival / tour start)
INSERT INTO payment (
    booking_id, installment, amount, payment_method, received_date, 
    recorded_by, status, slip_url, notes, created_at
)
SELECT 
    b.booking_id,
    'FINAL',
    ROUND((b.quoted_price * 0.70 + b.additional_charges)::NUMERIC, 2),
    (ARRAY['CASH', 'BANK_TRANSFER', 'CASH'])[1 + (b.booking_id % 3)]::payment_method_type,
    b.start_date,
    1 + ((b.booking_id + 3) % 10),
    'APPROVED',
    NULL,
    'Sample final settlement recorded at tour commencement; demo data only.',
    b.start_date::TIMESTAMPTZ + interval '9 hours'
FROM booking b
WHERE b.booking_status IN ('TOUR_STARTED', 'COMPLETED', 'CLOSED');

-- Pending unverified payments (customers uploaded bank slips awaiting admin verification)
INSERT INTO payment (
    booking_id, installment, amount, payment_method, received_date, 
    recorded_by, status, slip_url, notes, created_at
)
SELECT 
    b.booking_id,
    'ADVANCE',
    ROUND((b.quoted_price * 0.30)::NUMERIC, 2),
    'BANK_TRANSFER'::payment_method_type,
    NULL,
    NULL,
    'PENDING',
    NULL,
    'Sample bank-transfer payment awaiting admin verification; no real slip is attached.',
    b.booking_date::TIMESTAMPTZ + interval '14 hours'
FROM booking b
WHERE b.booking_status = 'ACCEPTED';

-- =========================================================
-- 12. REVIEWS (synthetic sample feedback; not verified customer testimonials)
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
    (ARRAY['Demo Driver 01', 'Demo Driver 02', 'Demo Driver 03', 'Demo Driver 04', 'Demo Driver 05', 'Demo Driver 06', 'Demo Driver 07', 'Demo Driver 08'])[1 + (b.booking_id % 8)] AS driver_name,
    (ARRAY['Enjoyable Sri Lanka trip', 'Comfortable vehicle and helpful driver', 'Good communication throughout the trip', 'Scenic journey and punctual service', 'Pleasant travel experience', 'Would recommend the transport service'])[1 + (b.booking_id % 6)] AS title,
    (ARRAY[
        'The driver was punctual and the vehicle was clean. Communication before pickup was clear.',
        'The journey was comfortable and the driver was helpful with route and stop information.',
        'The vehicle was suitable for our group and the trip was organised well.',
        'Pickup arrangements were smooth and the driver maintained a professional manner.',
        'We enjoyed the journey and appreciated the clear communication from the booking team.'
    ])[1 + (b.booking_id % 5)] AS feedback,
    b.completed_at + interval '2 days'
FROM booking b
WHERE b.booking_status IN ('COMPLETED', 'CLOSED')
  AND b.booking_id % 2 = 0; -- ~50% review completion rate

-- Review images are intentionally not seeded. Add a row only after a real uploaded image URL exists.

-- =========================================================
-- 13. SUPPORT, CONTACT INQUIRIES & REPLIES (800 Inquiries)
-- =========================================================
INSERT INTO contact_inquiry (sender_name, sender_email, sender_phone, subject, message, is_read, status, submitted_at)
SELECT 
    u.name,
    u.email,
    u.contact_number,
    (ARRAY['Availability of a vehicle for four passengers', 'Luggage capacity for a family booking', 'Child seat availability', 'Tourist van availability for a group', 'Airport pickup arrangement', 'Availability of a wildlife safari package'])[1 + (i % 6)],
    CASE (i % 6)
        WHEN 0 THEN 'Hello, we are travelling from ' || u.country || ' and would like to check vehicle availability and the daily rate for four passengers.'
        WHEN 1 THEN 'Hello, we are travelling from ' || u.country || ' and would like to confirm the luggage capacity for our family and selected vehicle.'
        WHEN 2 THEN 'Hello, we are travelling from ' || u.country || ' and would like to ask whether a child seat can be arranged for our booking.'
        WHEN 3 THEN 'Hello, we are travelling from ' || u.country || ' and need a suitable air-conditioned van for our group. Please share the available options.'
        WHEN 4 THEN 'Hello, we are travelling from ' || u.country || ' and would like to arrange an airport pickup. Please confirm the pickup process and estimated cost.'
        ELSE 'Hello, we are travelling from ' || u.country || ' and would like information about the available wildlife safari packages.'
    END,
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
    'Ayubowan ' || ci.sender_name || ', thank you for contacting us. Our team will check the relevant vehicle or package details and confirm availability, inclusions and pricing before your booking is finalised.',
    ci.submitted_at + interval '1 hour 45 minutes'
FROM contact_inquiry ci;

-- =========================================================
-- 14. BOOKING STATUS HISTORY (Audited Lifecycle Transitions)
-- =========================================================
-- 1. Initial booking submission
INSERT INTO booking_status_history (booking_id, old_status, new_status, admin_note, changed_at)
SELECT 
    b.booking_id,
    NULL,
    'PENDING'::booking_status_type,
    'Customer inquiry submitted via online booking portal.',
    b.booking_date::TIMESTAMPTZ + interval '10 minutes'
FROM booking b;

-- 2. Itinerary quotation sent
INSERT INTO booking_status_history (booking_id, old_status, new_status, admin_note, changed_at)
SELECT 
    b.booking_id,
    'PENDING'::booking_status_type,
    'QUOTED'::booking_status_type,
    'Official itinerary quotation and pricing dispatched to customer.',
    b.quoted_at
FROM booking b
WHERE b.quoted_at IS NOT NULL;

-- 3. Customer accepted quote
INSERT INTO booking_status_history (booking_id, old_status, new_status, admin_note, changed_at)
SELECT 
    b.booking_id,
    'QUOTED'::booking_status_type,
    'ACCEPTED'::booking_status_type,
    'Customer accepted tour quote terms and requested payment gateway details.',
    b.quoted_at + interval '6 hours'
FROM booking b
WHERE b.booking_status IN ('ACCEPTED', 'CONFIRMED', 'TOUR_STARTED', 'COMPLETED', 'CLOSED');

-- 4. Advance payment verified and tour confirmed
INSERT INTO booking_status_history (booking_id, old_status, new_status, admin_note, changed_at)
SELECT 
    b.booking_id,
    'ACCEPTED'::booking_status_type,
    'CONFIRMED'::booking_status_type,
    'Advance deposit verified by finance desk. Dedicated vehicle and chauffeur reserved.',
    b.confirmed_at
FROM booking b
WHERE b.confirmed_at IS NOT NULL;

-- 5. Cancelled tours
INSERT INTO booking_status_history (booking_id, old_status, new_status, admin_note, changed_at)
SELECT 
    b.booking_id,
    'CONFIRMED'::booking_status_type,
    'CANCELLED'::booking_status_type,
    'Customer cancelled booking due to flight schedule alterations.',
    b.booking_date::TIMESTAMPTZ + interval '3 days'
FROM booking b
WHERE b.booking_status = 'CANCELLED';

-- 6. Tour commenced
INSERT INTO booking_status_history (booking_id, old_status, new_status, admin_note, changed_at)
SELECT 
    b.booking_id,
    'CONFIRMED'::booking_status_type,
    'TOUR_STARTED'::booking_status_type,
    'Chauffeur met client at airport arrival terminal. Tour officially commenced.',
    b.tour_started_at
FROM booking b
WHERE b.tour_started_at IS NOT NULL;

-- 7. Tour completed
INSERT INTO booking_status_history (booking_id, old_status, new_status, admin_note, changed_at)
SELECT 
    b.booking_id,
    'TOUR_STARTED'::booking_status_type,
    'COMPLETED'::booking_status_type,
    'Tour itinerary executed completely. Guest arrived at departure terminal safely.',
    b.completed_at
FROM booking b
WHERE b.completed_at IS NOT NULL;

-- 8. Final audit and closed
INSERT INTO booking_status_history (booking_id, old_status, new_status, admin_note, changed_at)
SELECT 
    b.booking_id,
    'COMPLETED'::booking_status_type,
    'CLOSED'::booking_status_type,
    'Final financial audit reconciled and feedback review processed.',
    b.closed_at
FROM booking b
WHERE b.closed_at IS NOT NULL;

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
UNION ALL SELECT 'booking_status_history', count(*) FROM booking_status_history;

select * from place;
select * from package;
