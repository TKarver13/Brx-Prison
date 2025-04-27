Config = {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true' -- Use qb-target interactions (don't change this, go to your server.cfg and add `setr UseTarget true` to use this and just that from true to false or the other way around)
Config.Notify = 'ox'
Config.Target = 'qb'

Config.Jobs = { 
    ['electrician'] = 'Sparky',
    ['plumber'] = 'Mario',
    ['janitor'] = 'Wrenchy',
}

Config.Food = {
    x = 1780.87,
    y = 2559.72,
    z = 45.60,
}
Config.Drink = {
    x = 1777.83,
    y = 2559.82,
    z = 45.60,
}

 Config.Uniforms = {
    ['male'] = {
        outfitData = {
            ['t-shirt'] = { item = 15, texture = 0 },
            ['torso2'] = { item = 363, texture = 2 },
            ['arms'] = { item = 0, texture = 0 },
            ['pants'] = { item = 134, texture = 2 },
            ['shoes'] = { item = 112, texture = 0 },
            ["accessory"] = {item = 0, texture = 0}, -- Neck Accessory
            ["bag"] = {item = 0, texture = 0}, -- Bag
            ["hat"] = {item = -1, texture = -1}, -- Hat
            ["glass"] = {item = 0, texture = 0}, -- Glasses
            ["mask"] = {item = 0, texture = 0} -- Mask
        }
    },
    ['female'] = {
        outfitData = {
            ['t-shirt'] = { item = 3, texture = 0 },
            ['torso2'] = { item = 382, texture = 2 },
            ['arms'] = { item = 0, texture = 0 },
            ['pants'] = { item = 141, texture = 2 },
            ['shoes'] = { item = 116, texture = 0 },
            ["accessory"] = {item = 0, texture = 0}, -- Neck Accessory
            ["bag"] = {item = 0, texture = 0}, -- Bag
            ["hat"] = {item = -1, texture = -1}, -- Hat
            ["glass"] = {item = 0, texture = 0}, -- Glasses
            ["mask"] = {item = 0, texture = 0} -- Mask
        }
    },
}

Config.Locations = {
    freedom = vector4(1817.78, 2592.74, 44.72, 57.31),
    outside = vector4(1848.13, 2586.05, 44.67, 269.5),
    yard = vector4(1754.02, 2501.77, 45.61, 42),
    middle = vector4(1693.33, 2569.51, 44.55, 123.5),
    medical = vector4(1765.65, 2566.16, 45.57, 359),
    cafe = vector4(1780.19, 2558.99, 45.67, 359),
    prison = vector4(1846.42, 2602.55, 45.60, 270),
    spawns = {
        { coords = vector4(1748.70, 2490.19, 49.69, 208) },
        { coords = vector4(1755.05, 2493.72, 49.69, 209) },
        { coords = vector4(1761.50, 2497.44, 49.69, 204) },
        { coords = vector4(1767.66, 2501.00, 49.69, 209) },
        { coords = vector4(1777.41, 2483.21, 49.69, 27) },
        { coords = vector4(1771.09, 2479.53, 49.69, 27) },
        { coords = vector4(1764.80, 2476.06, 49.69, 27) },
        { coords = vector4(1758.40, 2472.55, 49.69, 25) },
        { coords = vector4(1774.12, 2481.50, 45.74, 30) },
        { coords = vector4(1764.52, 2498.89, 45.74, 210) },
        { coords = vector4(1761.74, 2474.05, 45.74, 30) },
        { coords = vector4(1751.77, 2491.95, 45.74, 210) }
    },
    jobs = {
        electrician = {
            { coords = vector4(1761.46, 2540.41, 45.56, 272.249) },
            { coords = vector4(1718.54, 2527.802, 45.56, 272.249) },
            { coords = vector4(1700.199, 2474.811, 45.56, 272.249) },
            { coords = vector4(1664.827, 2501.58, 45.56, 272.249) },
            { coords = vector4(1621.622, 2509.302, 45.56, 272.249) },
            { coords = vector4(1627.936, 2538.393, 45.56, 272.249) },
            { coords = vector4(1625.1, 2575.988, 45.56, 272.249) }
        },
        plumber = {
            { coords = vector4(1767.13, 2530.47, 45.57, 232) },
            { coords = vector4(1722.72, 2504.87, 45.56, 224) },
            { coords = vector4(1718.24, 2487.72, 45.56, 184) },
            { coords = vector4(1667.05, 2487.84, 45.56, 181) },
            { coords = vector4(1617.57, 2521.65, 45.56, 144) },
            { coords = vector4(1616.56, 2579.49, 45.56, 87) },
            { coords = vector4(1778.56, 2564.42, 45.67, 354) }
        },
        janitor = {
            { coords = vector4(1783.28, 2564.11, 45.67, 356) },
            { coords = vector4(1732.53, 2545.42, 43.58, 340) },
            { coords = vector4(1742.99, 2530.84, 43.59, 295) },
            { coords = vector4(1631.06, 2527.61, 45.56, 176) },
            { coords = vector4(1685.88, 2553.72, 45.56, 359) },
            { coords = vector4(1754.20, 2475.13, 45.74, 208) },
            { coords = vector4(1778.26, 2546.18, 45.67, 174) }
        }
    }
}


Config.BobSpawn = vector4(1735.39, 2576.50, 45.56, 174) --vector4(1745.51, 2484.06, 45.74, 212) Location for When LIVE

Config.BobJobs = {
    {
        name = "yard_cleaning",
        label = "Clean Up The Yard",
        jailtimeRequired = 5, --base 50
        pickups = {
            { coords = vector4(1770.03, 2490.12, 45.74, 106) },
            { coords = vector4(1759.97, 2483.50, 45.74, 55) },
            { coords = vector4(1763.50, 2488.20, 45.74, 186) },
        },
        reward = 1
    },

        {
        name = "contraband_delivery",
        label = "Deliver Contraband",
        jailtimeRequired = 300,
        pickups = {
            { coords = vector4(1770.03, 2490.12, 45.74, 106) },
            { coords = vector4(1759.97, 2483.50, 45.74, 55) },
            { coords = vector4(1763.50, 2488.20, 45.74, 186) },
        },
        reward = 2
    },

        {
        name = "collect_debt",
        label = "Collect Debts",
        jailtimeRequired = 500,
        pickups = {
            { coords = vector4(1770.03, 2490.12, 45.74, 106) },
            { coords = vector4(1759.97, 2483.50, 45.74, 55) },
            { coords = vector4(1763.50, 2488.20, 45.74, 186) },
        },
        reward = 3
    },

        {
        name = "kill_snitch",
            label = "Eliminate a Snitch",
            jailtimeRequired = 700,
            targetSpawn = vector4(1726.13, 2553.55, 43.59, 178), -- Where the target spawns
            reward = 5
    },

        {
        name = "buy_something",
        label = "Buy Something",
        jailtimeRequired = 1000,
    },

    -- Add more jobs here if needed
}

Config.HiddenStashItems = {

    {"rolledbills", 1, 2, 40},
    {"lockpick", 1, 3, 35},
    {"steel", 1, 20, 30},
    {"metalscrap", 1, 20, 20},
    {"weapon_bottle", 1, 1, 10},

}


Config.StashItems = {
    "hiddenstashitem",
    "hiddenstashitem",
    "hiddenstashitem",
    "hiddenstashitem",
    "hiddenstashitem"
}

Config.StashLocations = {
    { coords = vector4(1756.32, 2495.58, 49.90, 178) },
    { coords = vector4(1790.66, 2569.25, 44.57, 0)}, 

    { coords = vector4(1788.63, 2540.75, 44.57, 0)},
    { coords = vector4(1786.21, 2565.1, 44.76, 0)},

    { coords = vector4(1787.56, 2565.1, 44.76, 0)},
    { coords = vector4(1776.79, 2560.82, 44.68, 0)},

    { coords = vector4(1777.46, 2565.07, 45.05, 0)},
    { coords = vector4(1774.31, 2564.75, 44.41, 0)},

    { coords = vector4(1736.08, 2563.99, 44.57, 0)},
    { coords = vector4(1722.94, 2554.92, 44.54, 0)},

    { coords = vector4(1625.6, 2578.51, 44.56, 0)},
    { coords = vector4(1632.51, 2528.37, 44.56, 0)},

    { coords = vector4(1640.88, 2489.85, 44.56, 0)},
    { coords = vector4(1725.02, 2489.43, 44.56, 0)},

    { coords = vector4(1740.67, 2482.27, 44.74, 0)},
    { coords = vector4(1785.01, 2539.79, 45.59, 80)}
}


Config.TheStash = {

    { 
    Name = "thestash",   
    Location = vector3(1688.04, 2553.79, 44.59),   
    Width = 1.5,    
    Height = 1.5,       
    heading = 0.0,  
    MinZ = 45.15,    
    MaxZ = 45.55,    
    Icon = 'fa-solid fa-box-archive',      
    Label = '?',            
    Size = vec3(1.2, 1.2, 1.2),   
    Event = 'brx-prison:client:OpenStash',
    },

}