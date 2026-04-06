# Ridgeline Nature Preserve — Wildlife Explorer

An interactive web application for exploring a fictional mountain nature preserve in the Colorado Front Range. Built as a single-page app with a Leaflet.js map and a live Supabase (PostgreSQL) backend.

**Live site:** https://kalchikee.github.io/ridgeline-nature-preserve/

---

## About the Park

Ridgeline Nature Preserve is a 2,185-acre montane wilderness area with elevations ranging from 7,800 to 9,240 feet. The preserve contains four distinct habitat zones:

| Habitat | Acres | Description |
|---|---|---|
| Montane Forest | 1,240 | Dense stands of ponderosa pine and Douglas fir draped across the mid-slopes, sheltering mule deer, black bears, and over 60 bird species |
| Alpine Meadow | 380 | Open high-country meadow that erupts with native wildflowers each summer — peak bloom runs late June through August with elk grazing the edges at dusk |
| Riparian Zone | 210 | A living corridor of cottonwood and willow threading along Ridgeline Creek, with beaver lodges, great blue herons, and the highest wildlife diversity per acre in the preserve |
| Rocky Outcrop | 155 | Sun-warmed granite and limestone shelves where pikas squeak from boulder piles, marmots bask in the open, and swallows nest along the cliff faces |

---

## Features

The app is organized around a bottom tab bar with five sections:

### Explore
Overview of the preserve with live database stats (total sightings, unique species, most common category), habitat zone summary, and a list of wildlife hotspots the user can tap to fly to on the map.

### Trails
Five trails color-coded by difficulty with distance, surface type, and description. Filter by difficulty level to find a trail that suits your fitness.

| Trail | Difficulty | Distance |
|---|---|---|
| Old Growth Spur | Easy | 1.1 mi |
| Meadow Loop | Easy | 1.8 mi |
| Pika Boulder Trail | Moderate | 2.4 mi |
| Creekside Path | Moderate | 3.1 mi |
| Summit Ridge Trail | Hard | 5.2 mi |

### Report
Submit a wildlife sighting through a validated form. Set your location by tapping the map or using the GPS button. Sightings are inserted directly into the Supabase database and appear on the map immediately without a page reload.

### Sightings
Browse all visitor-submitted wildlife sightings from the database. Filter by:
- **Category** — mammal, bird, reptile, amphibian, insect, plant, other
- **Date range** — all time, last 30 days, last 7 days
- **Species search** — real-time text search by species name

### Layers
Toggle each of the six map layers on and off independently.

---

## Map Layers

| Layer | Type | Source |
|---|---|---|
| Park Boundary | Polygon | Embedded GeoJSON |
| Habitat Zones | Polygon | Embedded GeoJSON |
| Trails | LineString | Embedded GeoJSON |
| Wildlife Hotspots | Point | Embedded GeoJSON |
| Points of Interest | Point | Embedded GeoJSON |
| Visitor Sightings | Point | Supabase (live) |

---

## Tech Stack

| Component | Technology |
|---|---|
| Map | [Leaflet.js](https://leafletjs.com/) 1.9.4 |
| Basemap | ESRI World Topo |
| Database | [Supabase](https://supabase.com/) (PostgreSQL) |
| Icons | Bootstrap Icons 1.11 |
| Hosting | GitHub Pages |

The app is a single HTML file with no build step or framework required.

---

## Database Schema

The only user-writable table is `wildlife_sightings`. All other data (trails, habitats, hotspots, POIs) is embedded as GeoJSON in the client.

```sql
CREATE TABLE wildlife_sightings (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  species        TEXT        NOT NULL CHECK (char_length(species) >= 2),
  category       TEXT        NOT NULL CHECK (category IN ('mammal','bird','reptile','amphibian','insect','plant','other')),
  sighting_date  DATE        NOT NULL DEFAULT CURRENT_DATE,
  description    TEXT,
  submitter_name TEXT,
  lat            FLOAT8      NOT NULL CHECK (lat  BETWEEN 38.818 AND 38.884),
  lng            FLOAT8      NOT NULL CHECK (lng  BETWEEN -104.960 AND -104.882),
  created_at     TIMESTAMPTZ DEFAULT now()
);
```

Row Level Security is enabled with public read and public insert policies so anonymous users can browse and submit sightings without authentication.

