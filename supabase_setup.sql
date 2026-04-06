-- =============================================================
--  Ridgeline Nature Preserve — Supabase Database Schema
--  Run this in: Supabase Dashboard → SQL Editor → New Query
-- =============================================================

-- ── Wildlife sightings (user-submitted) ──────────────────────
CREATE TABLE IF NOT EXISTS wildlife_sightings (
  id             uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  species        text        NOT NULL CHECK (char_length(species) >= 2),
  category       text        NOT NULL CHECK (category IN ('mammal','bird','reptile','amphibian','insect','plant','other')),
  sighting_date  date        NOT NULL DEFAULT CURRENT_DATE,
  description    text,
  submitter_name text,
  lat            float8      NOT NULL CHECK (lat BETWEEN 38.818 AND 38.884),
  lng            float8      NOT NULL CHECK (lng BETWEEN -104.960 AND -104.882),
  created_at     timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_sightings_category ON wildlife_sightings (category);
CREATE INDEX IF NOT EXISTS idx_sightings_date     ON wildlife_sightings (sighting_date DESC);

ALTER TABLE wildlife_sightings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public_read"   ON wildlife_sightings FOR SELECT USING (true);
CREATE POLICY "public_insert" ON wildlife_sightings FOR INSERT WITH CHECK (true);

-- ── Park boundary ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS park_boundary (
  id          serial  PRIMARY KEY,
  name        text    NOT NULL,
  area_acres  int,
  coordinates jsonb   NOT NULL   -- [[lng,lat], ...] outer ring
);

ALTER TABLE park_boundary ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public_read" ON park_boundary FOR SELECT USING (true);

INSERT INTO park_boundary (name, area_acres, coordinates) VALUES
('Ridgeline Nature Preserve', 2185,
 '[[-104.960,38.818],[-104.882,38.818],[-104.882,38.884],[-104.960,38.884],[-104.960,38.818]]');

-- ── Habitat zones ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS habitat_zones (
  id          serial  PRIMARY KEY,
  name        text    NOT NULL,
  type        text    NOT NULL,
  area_acres  int,
  description text,
  coordinates jsonb   NOT NULL   -- [[lng,lat], ...] outer ring
);

ALTER TABLE habitat_zones ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public_read" ON habitat_zones FOR SELECT USING (true);

INSERT INTO habitat_zones (name, type, area_acres, description, coordinates) VALUES
('Montane Forest', 'forest', 1240,
 'Ponderosa pine and Douglas fir forest covering the mid-slopes. Supports mule deer, black bears, and over 60 bird species including multiple woodpecker species.',
 '[[-104.942,38.855],[-104.920,38.856],[-104.900,38.866],[-104.895,38.880],[-104.910,38.883],[-104.937,38.876],[-104.943,38.866],[-104.942,38.855]]'),
('Alpine Meadow', 'meadow', 380,
 'High-elevation meadow with native grasses and summer wildflowers. Prime elk summer habitat; over 40 wildflower species documented. Peak bloom July–August.',
 '[[-104.912,38.865],[-104.896,38.869],[-104.890,38.882],[-104.907,38.883],[-104.914,38.878],[-104.912,38.865]]'),
('Riparian Zone', 'riparian', 210,
 'Cottonwood and willow corridor along Ridgeline Creek. Rich in amphibians, songbirds, and beaver activity. Highest wildlife diversity per acre in the preserve.',
 '[[-104.950,38.824],[-104.944,38.824],[-104.938,38.862],[-104.930,38.873],[-104.934,38.874],[-104.942,38.863],[-104.950,38.826],[-104.950,38.824]]'),
('Rocky Outcrop', 'rocky', 155,
 'Exposed granite and limestone formations. Habitat for American pikas, yellow-bellied marmots, and cliff-nesting swallows. Listen for the pika''s distinctive alarm calls.',
 '[[-104.908,38.824],[-104.895,38.827],[-104.891,38.838],[-104.900,38.840],[-104.910,38.835],[-104.910,38.824],[-104.908,38.824]]');

-- ── Trails ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS trails (
  id          serial  PRIMARY KEY,
  name        text    NOT NULL,
  difficulty  text    NOT NULL CHECK (difficulty IN ('Easy','Moderate','Hard')),
  length_mi   float4,
  surface     text,
  description text,
  coordinates jsonb   NOT NULL   -- [[lng,lat], ...]
);

ALTER TABLE trails ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public_read" ON trails FOR SELECT USING (true);

INSERT INTO trails (name, difficulty, length_mi, surface, description, coordinates) VALUES
('Summit Ridge Trail', 'Hard', 5.2, 'Rocky',
 'A challenging ascent to the preserve''s highest point at 9,240 ft. Strenuous switchbacks above treeline reward hikers with 360° panoramic views. Bring extra water and layers — weather changes fast above treeline.',
 '[[-104.948,38.827],[-104.935,38.840],[-104.920,38.852],[-104.902,38.862],[-104.893,38.876]]'),
('Meadow Loop', 'Easy', 1.8, 'Packed gravel',
 'A gentle loop through the heart of the wildflower meadow. Excellent for families, birding, and casual nature walks. Accessible year-round; best in summer for bloom.',
 '[[-104.927,38.844],[-104.919,38.852],[-104.912,38.848],[-104.915,38.840],[-104.924,38.842],[-104.927,38.844]]'),
('Creekside Path', 'Moderate', 3.1, 'Natural',
 'Follows Ridgeline Creek through lush riparian habitat. Expect muddy sections in spring. Outstanding wildlife viewing all year — watch for beaver activity near the pond.',
 '[[-104.948,38.827],[-104.945,38.836],[-104.942,38.848],[-104.939,38.860],[-104.932,38.872]]');

-- ── Wildlife hotspots ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS wildlife_hotspots (
  id          serial  PRIMARY KEY,
  name        text    NOT NULL,
  species     text,
  category    text,
  best_time   text,
  description text,
  lat         float8  NOT NULL,
  lng         float8  NOT NULL
);

ALTER TABLE wildlife_hotspots ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public_read" ON wildlife_hotspots FOR SELECT USING (true);

INSERT INTO wildlife_hotspots (name, species, category, best_time, description, lat, lng) VALUES
('Eagle''s Nest Overlook', 'Bald Eagle, Golden Eagle', 'Raptors', 'Early morning (6–9 am)',
 'Granite outcrop with open valley views. Eagles soar on morning thermals and perch in the ponderosas below. Bring binoculars.',
 38.872, -104.897),
('Deer Meadow', 'White-tailed Deer, Elk, Wild Turkey', 'Ungulates & Birds', 'Dawn and dusk',
 'Open meadow where deer and elk graze. Wild turkeys forage along the forest edge in the afternoons. Avoid loud noises and bright colors.',
 38.847, -104.918),
('Beaver Pond', 'American Beaver, Great Blue Heron, Wood Duck', 'Wetland Wildlife', 'Early morning',
 'Active beaver dam with open water. Herons fish from the bank at dawn; ducks nest in cattails along the south edge. Stay on the designated viewing bench.',
 38.862, -104.940),
('Fox Den Area', 'Red Fox, Coyote, Mule Deer', 'Mammals', 'Morning and evening',
 'Known red fox denning site beneath a granite ledge. Stay quiet and remain downwind for the best chance of seeing kits in spring (April–June).',
 38.833, -104.930),
('Raptor Ridge', 'Red-tailed Hawk, Turkey Vulture, American Kestrel', 'Raptors', 'Midday thermals (11 am–2 pm)',
 'The main ridge generates strong thermal updrafts used by multiple raptor species for effortless soaring. Ideal midday photography with bright light.',
 38.878, -104.908);

-- ── Points of interest ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS points_of_interest (
  id          serial  PRIMARY KEY,
  name        text    NOT NULL,
  type        text,
  icon        text,
  description text,
  lat         float8  NOT NULL,
  lng         float8  NOT NULL
);

ALTER TABLE points_of_interest ENABLE ROW LEVEL SECURITY;
CREATE POLICY "public_read" ON points_of_interest FOR SELECT USING (true);

INSERT INTO points_of_interest (name, type, icon, description, lat, lng) VALUES
('Visitor Center', 'trailhead', '🏛️',
 'Park HQ with maps, restrooms, first-aid station, and ranger staff. All three trailheads begin here. Open daily 8 am–6 pm.',
 38.827, -104.948),
('Summit Overlook', 'viewpoint', '🔭',
 '360° panoramic views from 9,240 ft — the highest point in the preserve. Bench and interpretive signage. Accessible via Summit Ridge Trail.',
 38.876, -104.893),
('Beaver Pond Bench', 'picnic', '🌿',
 'Peaceful bench overlooking the active beaver pond. Excellent wildlife photography spot. Accessible from the Creekside Path.',
 38.861, -104.941),
('Old Growth Grove', 'feature', '🌲',
 'Ancient ponderosa pines — some over 300 years old. Dense shade canopy supports cavity-nesting birds including Pygmy Nuthatch and Northern Flicker.',
 38.855, -104.928),
('Wildflower Meadow', 'feature', '🌸',
 'Over 40 native wildflower species documented including Blue Columbine, Indian Paintbrush, and Yarrow. Peak bloom late June–August.',
 38.848, -104.916),
('Rocky Creek Crossing', 'feature', '💧',
 'Scenic ford of Ridgeline Creek. High water in May–June; stepping stones available July–October. Good spot for salamanders and water striders.',
 38.843, -104.943);

-- =============================================================
--  Seed: example wildlife sightings so the app isn''t empty
-- =============================================================
INSERT INTO wildlife_sightings (species, category, sighting_date, description, submitter_name, lat, lng) VALUES
  ('Bald Eagle',      'bird',      '2025-07-14', 'Adult perched in a ponderosa near the overlook for 20 minutes.',         'Park Ranger',   38.872, -104.897),
  ('Mule Deer',       'mammal',    '2025-07-15', 'Small herd of 6 does in the meadow at dawn.',                            'Park Ranger',   38.847, -104.918),
  ('American Beaver', 'mammal',    '2025-07-16', 'Actively maintaining the dam; fresh mud visible on the lodge.',           'Park Ranger',   38.862, -104.940),
  ('Red Fox',         'mammal',    '2025-08-02', 'Two kits seen playing near the den entrance in the evening.',             'J. Ramirez',    38.833, -104.930),
  ('Great Blue Heron','bird',      '2025-08-10', 'Fishing along the south edge of the beaver pond, stood still for 10 min.','T. Walsh',      38.861, -104.941),
  ('Western Tiger Salamander','amphibian','2025-08-18','Found crossing trail near Rocky Creek Crossing after rain.',         'A. Chen',       38.843, -104.943),
  ('Golden Eagle',    'bird',      '2025-09-01', 'Juvenile soaring on thermals above Raptor Ridge for 30 minutes.',         'Park Ranger',   38.878, -104.908),
  ('Elk',             'mammal',    '2025-09-12', 'Bull elk bugling in the alpine meadow, heard from the summit trail.',      'M. Torres',     38.869, -104.905),
  ('Steller''s Jay',  'bird',      '2025-07-20', 'Pair foraging near the Old Growth Grove, very loud and curious.',           'Park Ranger',   38.855, -104.928),
  ('American Pika',   'mammal',    '2025-07-28', 'Heard alarm calls from the rocky outcrop, spotted one carrying grass.',     'S. Nguyen',     38.832, -104.903),
  ('Black Bear',      'mammal',    '2025-08-05', 'Subadult bear foraging for berries on the forest edge near Creekside Path.','Park Ranger',   38.848, -104.939),
  ('Mountain Bluebird','bird',     '2025-08-08', 'Brilliant blue male perched on a fence post near the meadow trailhead.',    'L. Patterson',  38.844, -104.924),
  ('Yellow-bellied Marmot','mammal','2025-08-14','Colony of 4 sunning on granite boulders at the rocky outcrop.',             'R. Kim',        38.834, -104.900),
  ('Northern Flicker', 'bird',     '2025-08-22', 'Drumming loudly on a dead snag in the Old Growth Grove, very close view.', 'D. Okonkwo',    38.856, -104.930),
  ('Western Rattlesnake','reptile','2025-08-29', 'Coiled on a warm south-facing rock near the Fox Den Area. Left undisturbed.','Park Ranger',  38.831, -104.928),
  ('Tiger Swallowtail','insect',   '2025-09-03', 'Dozens nectaring on late-season wildflowers in the alpine meadow.',        'C. Flores',     38.871, -104.907),
  ('Coyote',          'mammal',    '2025-09-18', 'Single individual hunting in the meadow just after sunrise, watched for 15 min.','B. Larsen', 38.850, -104.920);

-- =============================================================
--  Additional sightings — run in Supabase SQL Editor to add
-- =============================================================
INSERT INTO wildlife_sightings (species, category, sighting_date, description, submitter_name, lat, lng) VALUES
  ('Osprey',               'bird',      '2025-09-22', 'Diving repeatedly into Ridgeline Creek near the beaver pond, caught a fish on the third attempt.',          'Park Ranger', 38.862, -104.940),
  ('Snowshoe Hare',        'mammal',    '2025-10-04', 'Coat already beginning to turn white for winter. Spotted near the forest edge at dusk.',                     'H. Brennan',  38.858, -104.931),
  ('Blue Columbine',       'plant',     '2025-07-11', 'Dense patch of Colorado state flower in full bloom along the Meadow Loop trail.',                            'Park Ranger', 38.848, -104.919),
  ('Western Fence Lizard', 'reptile',   '2025-08-19', 'Basking on a warm south-facing granite slab near the rocky outcrop. Bright blue belly visible.',             'T. Okafor',   38.831, -104.899),
  ('Common Poorwill',      'bird',      '2025-09-08', 'Heard calling at dusk from the forest edge, then flushed from the trail just after sunset.',                 'E. Vasquez',  38.853, -104.925),
  ('Boreal Chorus Frog',   'amphibian', '2025-06-03', 'Chorus of dozens heard calling from the marshy edge of the riparian zone after a rain.',                    'Park Ranger', 38.843, -104.944),
  ('Monarch Butterfly',    'insect',    '2025-09-14', 'Small southbound migration group of around 15 individuals nectaring on late-season wildflowers.',            'W. Griffith', 38.870, -104.906),
  ('Mountain Lion',        'mammal',    '2025-10-11', 'Fresh tracks in the mud along Creekside Path. Estimated large adult. Reported to ranger station.',           'Park Ranger', 38.849, -104.938),
  ('Hairy Woodpecker',     'bird',      '2025-08-27', 'Pair excavating a nest cavity in a dead ponderosa snag in the old growth grove. Very close and unconcerned.','N. Osei',     38.855, -104.929),
  ('Indian Paintbrush',    'plant',     '2025-07-18', 'Spectacular display of scarlet paintbrush scattered across the alpine meadow, mixed with blue columbine.',   'Park Ranger', 38.871, -104.903);
