Config = {}

Config.PurchasePrice = 50000

Config.CostForSupplyRun = 500
Config.SupplyAmount = math.random(1, 5)

Config.SupplyPickups = {
	vector3(493.2422, -742.8085, 24.8800),
	vector3(-31.8234, -95.3526, 57.2747),
	vector3(-2186.3926, -410.9326, 13.1014),
    vector3(-98.6061, -2232.1646, 7.8117),
    vector3(-1140.7611, -1594.3242, 4.3939),
    vector3(637.9090, 254.9665, 103.1521),
    vector3(1239.9482, -402.3115, 69.0110),
    vector3(1145.5824, -1008.4402, 44.9066),
    vector3(1450.6902, -1720.7283, 68.6998),
    vector3(975.6266, -2358.1860, 31.8238),
}

Config.CarWashes = {
    innocence = {
        location = 'Innocence',
        blip = {label = 'Carwash', sprite = 100, color = 2},
        washcoords = vector3(20.7795, -1391.8478, 29.3265),
        bosscoords = vector3(43.9, -1395.74, 29.98),
        qLength = 1,
        qWidth = 2,
        qHeading = 0,
        qMinZ = 27.98,
        qMaxZ = 31.98,
    },
    seoul = {
        location = 'Seoul',
        blip = {label = 'Carwash', sprite = 100, color = 2},
        washcoords = vector3(-699.8362, -933.0591, 19.0139),
        bosscoords = vector3(-702.84, -916.12, 19.21),
        qLength = 1.9,
        qWidth = 1,
        qHeading = 270,
        qMinZ = 16.81,
        qMaxZ = 20.81,
    },
    ottos = {
        location = 'Ottos',
        blip = {label = 'Carwash', sprite = 100, color = 2},
        washcoords = vector3(828.6793, -798.4175, 26.2284),
        bosscoords = vector3(825.39, -802.13, 26.33),
        qLength = 0.4,
        qWidth = 1,
        qHeading = 180,
        qMinZ = 26.18,
        qMaxZ = 27.78,
    },
    carson = {
        location = 'Carson',
        blip = {label = 'Carwash', sprite = 100, color = 2},
        washcoords = vector3(170.9855, -1717.9425, 29.2918),
        bosscoords = vector3(159.73, -1714.96, 29.29),
        qLength = 3.4,
        qWidth = 6,
        qHeading = 320,
        qMinZ = 27.89,
        qMaxZ = 31.89,
    },
    strawberry = {
        location = 'Strawberry',
        blip = {label = 'Carwash', sprite = 100, color = 2},
        washcoords = vector3(297.0608, -1247.2240, 29.2898),
        bosscoords = vector3(293.56, -1244.46, 29.27),
        qLength = 1.6,
        qWidth = 1,
        qHeading = 270,
        qMinZ = 28.47,
        qMaxZ = 32.47,
    },
}