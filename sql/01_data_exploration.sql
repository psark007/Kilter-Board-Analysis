/*
 * Kilter Board Data Exploration
 * 
 * We set out to understand the database structure, and to understand how this data actually models climbs on a Kilter Board.
 * This was originally done for the TB2 at gitlab.com/psark/Tension-Board-2-Analysis,
 * so we follow a similar pattern.
 * 
 * The database was downloaded in March 2026 via boardlib (https://github.com/lemeryfertitta/BoardLib).
 * It is clear from the `shared_syncs` table that (some of it) was updated on 2026-01-31.
 *
 */

-----------------------------------------------------------------------------------------------------------

/*
 * We first use our python script to get tables and row counts
 * 
table_name                     |       rows
---------------------------------------------
climb_stats                    |     348028
climbs                         |     344504
climb_cache_fields             |     208457
beta_links                     |      32139
leds                           |       7828
placements                     |       3773
holes                          |       3294
kits                           |        100
products_angles                |         56
product_sizes_layouts_sets     |         41
difficulty_grades              |         39
attempts                       |         38
placement_roles                |         30
product_sizes                  |         22
shared_syncs                   |         17
sets                           |         11
layouts                        |          8
products                       |          7
android_metadata               |          1
ascents                        |          0
bids                           |          0
circuits                       |          0
circuits_climbs                |          0
climb_random_positions         |          0
tags                           |          0
user_permissions               |          0
user_syncs                     |          0
users                          |          0
walls                          |          0
walls_sets                     |          0

 * 
 * climb_stats, climbs, and climb_cache fields are the biggest tables, with the former two being our main tables for analyzing climb data
 * beta_links just includes instagram links showing beta
 * 
 * Some Obesrvations:
 * - climb_stats has more entries than climbs, as it contains multiple entries per climb (multiple angles)
 * - placements/holes are reference tables for the physical board -- hole positions, holds, etc.
 * - placement roles are start/finish/middle/foot hold, etc.
 * - plenty of empty tables. Some should correspond to a specific user if you download the DB using broadlib with the -u flag. I couldn't get it working though.
 *
 * Let's start by looking at some sample data.
 * 
 */

/*
 * CLIMBS
 */

select * FROM climbs;
/*
uuid                            |layout_id|setter_id|setter_username    |name                         |description                             |hsm|edge_left|edge_right|edge_bottom|edge_top|angle|frames_count|frames_pace|frames                                                                                                                                                                                                                                                         |is_draft|is_listed|created_at                |is_nomatch|
--------------------------------+---------+---------+-------------------+-----------------------------+----------------------------------------+---+---------+----------+-----------+--------+-----+------------+-----------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------+---------+--------------------------+----------+
002047402B6941CEA5ED7BB09FBFE14D|        1|     1051|kilterjackie       |4/26 Harder Than It Should Be|                                        |  3|       40|       136|          4|     152|     |           1|          0|p1145r12p1146r12p1149r13p1186r13p1201r13p1256r15p1267r13p1276r15p1307r13p1321r13p1322r13p1343r13p1356r13p1392r14p1454r15p1455r15p1456r15p1457r15p1506r15p1523r15p1527r15p1533r15p1535r15                                                                       |       0|        0|2018-04-27 03:31:54.979371|         0|
002ED50792A94E5EB2127D59E167B2EE|        1|    17760|bctyner            |what kind of triangle        |Make sure you angle your body just right|  3|        4|       140|          4|     152|     |           1|          0|p1123r12p1139r13p1155r12p1171r13p1187r13p1203r13p1219r13p1235r13p1251r13p1267r13p1283r13p1299r13p1315r13p1331r13p1347r13p1363r13p1379r14p1447r15p1448r15p1449r15p1450r15p1451r15p1452r15p1453r15p1454r15p1455r15p1456r15p1457r15p1458r15p1459r15p1460r15p1461r1|       0|        0|2020-01-05 17:57:32.213641|         0|
003FF8E4DA8448E39696635E6DBD7B7C|        1|     8494|progressionclimbing|this is a statement          |                                        |  1|        8|       136|         16|     144|     |           1|          0|p1102r13p1123r13p1124r12p1127r12p1134r13p1148r13p1172r13p1176r13p1186r13p1191r13p1196r13p1216r13p1228r13p1232r13p1241r13p1254r13p1283r13p1285r13p1287r13p1291r13p1295r13p1298r13p1301r13p1332r13p1344r14p1345r13p1357r13p1367r13                               |       0|        0|2019-12-21 21:13:17.697354|         0|
004FB7A0C0754DA98634C5EE4D985D9A|        1|    45676|jefferoni          |SpEeD cLiMbInG               |                                        |  1|        8|       136|          8|     152|     |           1|          0|p1081r15p1090r13p1091r13p1094r12p1097r13p1098r15p1099r13p1102r12p1105r13p1106r13p1115r15p1132r15p1149r15p1166r15p1183r15p1200r15p1217r15p1234r15p1251r15p1268r15p1285r15p1302r15p1319r15p1336r15p1353r15p1370r15p1379r13p1380r13p1383r14p1386r13p1387r15p1388r1|       0|        0|2021-03-11 05:57:44.333209|         0|
00683d10a8e246b3a106531c8573f13c|        1|    44916|mark.nalder        |marks 1 try                  |                                        |  3|        4|        40|          4|     152|     |           1|          0|p1141r15p1142r12p1144r15p1179r12p1192r13p1246r13p1247r15p1260r13p1294r13p1331r13p1382r14p1461r15p1464r15                                                                                                                                                       |       0|        0|2020-10-20 21:31:19.064510|         0|
 *
 * The frames column is what actually determines which holds are on the climb, and which role they are.
 * Some other climbing characteristics (is_nomatch, description, setter info, edges, listed)
 * UUID is how we link the specific climb to other tables
 * 
 * Still no idea what hsm is.
 *
 */


SELECT * FROM climb_cache_fields;
/*
climb_uuid                      |ascensionist_count|display_difficulty|quality_average|
--------------------------------+------------------+------------------+---------------+
001E0BBB4A184D768684069740FCFC4B|                 2|              23.0|            3.0|
002047402B6941CEA5ED7BB09FBFE14D|                 1|              18.0|            1.0|
00243FB1C6C548B0AC98E1F8E6607859|                 1|              23.0|            2.0|
002ED50792A94E5EB2127D59E167B2EE|                 2|              25.0|            2.5|
0054AC30BDF34652AFD19E5ECC880B2A|                 1|              25.0|            3.0|
 *
 * climb_uuid, ascensionist_count, display_difficulty, quality_average
 */

SELECT * from climb_stats;
/*
climb_uuid                      |angle|display_difficulty|benchmark_difficulty|ascensionist_count|difficulty_average|quality_average|fa_username|fa_at              |
--------------------------------+-----+------------------+--------------------+------------------+------------------+---------------+-----------+-------------------+
00007DA715CE4E7DBF60928D240CE7F2|   50|              16.0|                    |                 1|              16.0|            1.0|whole_kogan|2021-01-10 19:11:45|
00079a6f946b4c26ba25123f77f41ea8|    5|              12.0|                    |                 1|              12.0|            3.0|djragan    |2020-10-14 01:45:30|
000B9FE6383B425EB74A977273F4E4DC|   10|           13.6364|                    |                11|           13.6364|        2.45455|Guill      |2019-02-14 19:33:04|
000B9FE6383B425EB74A977273F4E4DC|   45|           20.6667|                    |                 6|           20.6667|        2.16667|IzzuMizzu  |2019-08-31 07:14:14|
000C97C473E34860846BC29C2F7A8E47|   50|              16.0|                    |                 1|              16.0|            1.0|davekle    |2020-07-12 07:24:52|
 */

/*
 * Now let's take a look at the reason why climb_stats is much bigger than climbs. 
 */

SELECT COUNT(DISTINCT(cs.climb_uuid))
FROM climb_stats cs
JOIN climbs c ON cs.climb_uuid = c.uuid 
WHERE c.layout_id=1;
-- 186k unique climbs (not including angles)

-- can also see if we want to keep is_listed = 1 or not
SELECT COUNT(DISTINCT(cs.climb_uuid))
FROM climb_stats cs
JOIN climbs c ON cs.climb_uuid = c.uuid 
WHERE c.layout_id=1 AND c.is_listed =1;
/*
 * 174k as opposed to the 186k climbs.
 * We won't bother restricting ourselves with is_list=1 in the future.
 * 
 * Let's take a look at difficulty_grades.
 */

SELECT * FROM difficulty_grades;
/*
difficulty|boulder_name|route_name|is_listed|
----------+------------+----------+---------+
         1|1a/V0       |2b/5.1    |        0|
         2|1b/V0       |2c/5.2    |        0|
         3|1c/V0       |3a/5.3    |        0|
         4|2a/V0       |3b/5.3    |        0|
         5|2b/V0       |3c/5.4    |        0|
         6|2c/V0       |4a/5.5    |        0|
         7|3a/V0       |4b/5.6    |        0|
         8|3b/V0       |4c/5.7    |        0|
         9|3c/V0       |5a/5.8    |        0|
        10|4a/V0       |5b/5.9    |        1|
        11|4b/V0       |5c/5.10a  |        1|
        12|4c/V0       |6a/5.10b  |        1|
        13|5a/V1       |6a+/5.10c |        1|
        14|5b/V1       |6b/5.10d  |        1|
        15|5c/V2       |6b+/5.11a |        1|
        16|6a/V3       |6c/5.11b  |        1|
        17|6a+/V3      |6c+/5.11c |        1|
        18|6b/V4       |7a/5.11d  |        1|
        19|6b+/V4      |7a+/5.12a |        1|
        20|6c/V5       |7b/5.12b  |        1|
        21|6c+/V5      |7b+/5.12c |        1|
        22|7a/V6       |7c/5.12d  |        1|
        23|7a+/V7      |7c+/5.13a |        1|
        24|7b/V8       |8a/5.13b  |        1|
        25|7b+/V8      |8a+/5.13c |        1|
        26|7c/V9       |8b/5.13d  |        1|
        27|7c+/V10     |8b+/5.14a |        1|
        28|8a/V11      |8c/5.14b  |        1|
        29|8a+/V12     |8c+/5.14c |        1|
        30|8b/V13      |9a/5.14d  |        1|
        31|8b+/V14     |9a+/5.15a |        1|
        32|8c/V15      |9b/5.15b  |        1|
        33|8c+/V16     |9b+/5.15c |        1|
        34|9a/V17      |9c/5.15d  |        0|
        35|9a+/V18     |9c+/5.16a |        0|
        36|9b/V19      |10a/5.16b |        0|
        37|9b+/V20     |10a+/5.16c|        0|
        38|9c/V21      |10b/5.16d |        0|
        39|9c+/V22     |10b+/5.17a|        0|
 */

--------------------------------------------

/*
 * BOARDS, PLACEMENTS AND HOLDS
 * 
 */

/*
 * 
 * Let's examine each of thesse, starting with layouts.
 */


SELECT * from layouts;
/*
id|product_id|name                 |instagram_caption     |is_mirrored|is_listed|password |created_at                |
--+----------+---------------------+----------------------+-----------+---------+---------+--------------------------+
 1|         1|Kilter Board Original|                      |          0|        1|         |2015-12-31 20:02:31.000000|
 2|         2|JUUL                 |                      |          0|        1|freedom  |2019-05-26 17:35:44.426770|
 3|         3|Standard Medium      |Kilter's Demo Board.  |          0|        0|sales    |2019-07-29 23:35:36.435295|
 4|         4|BKBBoard Level 1     |                      |          0|        0|BKBlove  |2019-10-21 20:43:47.467242|
 6|         6|Tycho Complete       |                      |          0|        0|explore  |2020-07-21 20:48:59.728468|
 7|         6|Tycho 2020           |                      |          0|        1|explore  |2020-09-13 02:15:37.144386|
 8|         7|Kilter Board Homewall|The Kilter Home Board.|          0|        1|         |2020-10-02 17:19:05.122166|
 5|         5|Spire                |                      |          0|        0|SPIREDOJO|2020-04-29 01:19:34.621745|
 */

SELECT count(*), layout_id FROM CLIMBS GROUP BY layout_id;
/*
count(*)|layout_id|
--------+---------+
  315357|        1|
     160|        2|
       2|        3|
     637|        5|
       6|        6|
      12|        7|
   28330|        8|
 * 
 * We will restrict ourselves to the Kilter Board Original, i.e,. layout_id=1.
 * 
 * Let's take a look at products.
 */

SELECT * FROM products;
/*
id|name                 |is_listed|password|min_count_in_frame|max_count_in_frame|
--+---------------------+---------+--------+------------------+------------------+
 1|Kilter Board Original|        1|        |                 2|                35|
 7|Kilter Board Homewall|        1|        |                 2|                35|
 2|JUUL                 |        1|        |                 2|                35|
 3|Demo Board           |        0|        |                 2|                35|
 4|BKB Board            |        0|        |                 2|                35|
 6|Tycho                |        1|        |                 2|               120|
 5|Spire                |        0|        |                 2|                35|
 *
 * As with layout, we will stick to the Kilter Board Original
 */

SELECT * FROM products_angles  WHERE product_id=1;
/*
product_id|angle|
----------+-----+
         1|    0|
         1|    5|
         1|   10|
         1|   15|
         1|   20|
         1|   25|
         1|   30|
         1|   35|
         1|   40|
         1|   45|
         1|   50|
         1|   55|
         1|   60|
         1|   65|
         1|   70|
 *
 * Let's see product_sizes.
 */

SELECT * FROM product_sizes WHERE product_id=1;
/*
id|product_id|edge_left|edge_right|edge_bottom|edge_top|name                     |description|image_filename                  |position|is_listed|
--+----------+---------+----------+-----------+--------+-------------------------+-----------+--------------------------------+--------+---------+
 8|         1|       24|       120|          0|     156|8 x 12                   |Home       |product_sizes/8-transparent.png |       1|        1|
14|         1|       28|       116|         36|     156|7 x 10                   |Small      |product_sizes/14-transparent.png|       0|        1|
 7|         1|        0|       144|          0|     180|12 x 14                  |Commerical |product_sizes/7-transparent.png |       4|        1|
10|         1|        0|       144|          0|     156|12 x 12 with kickboard   |Square     |product_sizes/10-transparent.png|       2|        1|
27|         1|        0|       144|         12|     156|12 x 12 without kickboard|Square     |product_sizes/27-transparent.png|       3|        1|
28|         1|      -24|       168|          0|     156|16 x 12                  |Super Wide |product_sizes/28.png            |       5|        1|
 *  
 * Just tells us some info about different sized kilter boards. On to the layouts_sets.
 */

SELECT * FROM product_sizes_layouts_sets;
/*
id|product_size_id|layout_id|set_id|image_filename                                            |is_listed|
--+---------------+---------+------+----------------------------------------------------------+---------+
47|             11|        2|    21|product_sizes_layouts_sets/47.png                         |        1|
48|             12|        3|    22|product_sizes_layouts_sets/48.png                         |        1|
49|             13|        4|    23|product_sizes_layouts_sets/49.png                         |        1|
52|             15|        5|    24|product_sizes_layouts_sets/15_5_24.png                    |        1|
53|             16|        6|    25|product_sizes_layouts_sets/53.png                         |        1|
54|             16|        7|    25|product_sizes_layouts_sets/54.png                         |        1|
55|             17|        8|    26|product_sizes_layouts_sets/55-v2.png                      |        1|
56|             17|        8|    27|product_sizes_layouts_sets/56-v3.png                      |        1|
57|             18|        8|    26|product_sizes_layouts_sets/55-v2.png                      |        1|
58|             19|        8|    27|product_sizes_layouts_sets/56-v3.png                      |        1|
59|             20|        4|    23|product_sizes_layouts_sets/59.png                         |        1|
65|             23|        8|    28|product_sizes_layouts_sets/65-v2.png                      |        1|
66|             23|        8|    29|product_sizes_layouts_sets/66-v2.png                      |        1|
68|             24|        8|    28|product_sizes_layouts_sets/65-v2.png                      |        1|
69|             24|        8|    29|product_sizes_layouts_sets/66-v2.png                      |        1|
72|             25|        8|    28|product_sizes_layouts_sets/72.png                         |        1|
73|             25|        8|    29|product_sizes_layouts_sets/73.png                         |        1|
75|             26|        8|    28|product_sizes_layouts_sets/72.png                         |        1|
76|             26|        8|    29|product_sizes_layouts_sets/73.png                         |        1|
36|              7|        1|     1|product_sizes_layouts_sets/36-1.png                       |        1|
38|              7|        1|    20|product_sizes_layouts_sets/38-1.png                       |        1|
39|              8|        1|     1|product_sizes_layouts_sets/39-1.png                       |        1|
41|              8|        1|    20|product_sizes_layouts_sets/41-1.png                       |        1|
45|             10|        1|     1|product_sizes_layouts_sets/45-1.png                       |        1|
46|             10|        1|    20|product_sizes_layouts_sets/46-1.png                       |        1|
50|             14|        1|     1|product_sizes_layouts_sets/50-1.png                       |        1|
51|             14|        1|    20|product_sizes_layouts_sets/51-1.png                       |        1|
77|             27|        1|     1|product_sizes_layouts_sets/77-1.png                       |        1|
78|             27|        1|    20|product_sizes_layouts_sets/78-1.png                       |        1|
60|             21|        8|    26|product_sizes_layouts_sets/60-v3.png                      |        1|
62|             22|        8|    26|product_sizes_layouts_sets/60-v3.png                      |        1|
63|             23|        8|    26|product_sizes_layouts_sets/63-v3.png                      |        1|
67|             24|        8|    26|product_sizes_layouts_sets/63-v3.png                      |        1|
70|             25|        8|    26|product_sizes_layouts_sets/70-v2.png                      |        1|
74|             26|        8|    26|product_sizes_layouts_sets/70-v2.png                      |        1|
61|             21|        8|    27|product_sizes_layouts_sets/61-v3.png                      |        1|
64|             23|        8|    27|product_sizes_layouts_sets/64-v3.png                      |        1|
71|             25|        8|    27|product_sizes_layouts_sets/71-v3.png                      |        1|
79|             28|        1|     1|product_sizes_layouts_sets/original-16x12-bolt-ons-v2.png |        1|
80|             28|        1|    20|product_sizes_layouts_sets/original-16x12-screw-ons-v2.png|        1|
81|             29|        8|    27|product_sizes_layouts_sets/61-v3.png                      |        1|
 *
 * We will work with 16x12, so we will combine the two pictures with id 79 and 80 to get our overlay for later
 *
 */

-- restrict ourselves to layout_id=1
SELECT * FROM product_sizes_layouts_sets WHERE layout_id=1;
/*
id|product_size_id|layout_id|set_id|image_filename                                            |is_listed|
--+---------------+---------+------+----------------------------------------------------------+---------+
36|              7|        1|     1|product_sizes_layouts_sets/36-1.png                       |        1|
38|              7|        1|    20|product_sizes_layouts_sets/38-1.png                       |        1|
39|              8|        1|     1|product_sizes_layouts_sets/39-1.png                       |        1|
41|              8|        1|    20|product_sizes_layouts_sets/41-1.png                       |        1|
45|             10|        1|     1|product_sizes_layouts_sets/45-1.png                       |        1|
46|             10|        1|    20|product_sizes_layouts_sets/46-1.png                       |        1|
50|             14|        1|     1|product_sizes_layouts_sets/50-1.png                       |        1|
51|             14|        1|    20|product_sizes_layouts_sets/51-1.png                       |        1|
77|             27|        1|     1|product_sizes_layouts_sets/77-1.png                       |        1|
78|             27|        1|    20|product_sizes_layouts_sets/78-1.png                       |        1|
79|             28|        1|     1|product_sizes_layouts_sets/original-16x12-bolt-ons-v2.png |        1|
80|             28|        1|    20|product_sizes_layouts_sets/original-16x12-screw-ons-v2.png|        1|
 * 
 * We look work with the 16x12, containing both bolt-ons and screw-ons, since this encapsilates every original board (modulo the kickboard).
 * So product_size_id=28 will be our main interest.
 */

SELECT * FROM sets;
/* 
 * 
id|name               |hsm|
--+-------------------+---+
 1|Bolt Ons           |  1|
20|Screw Ons          |  2|
21|JUUL All           |  1|
22|Demo Holds         |  1|
23|BKB All            |  1|
24|Spire All          |  1|
25|Orbit              |  1|
26|Mainline           |  1|
27|Auxiliary          |  2|
28|Mainline Kickboard |  4|
29|Auxiliary Kickboard|  8|
 * 
 * We will do both bolt-ons and screw ons, so both set 1 and 20. 
 * 
 * What about the kickboard? One can add a kickboard if they want, where the bottom two rows of holds would go if anything. 
 * 
 * 
 * Next, let's look at placements.
 */

SELECT * FROM placements;
/*
id  |layout_id|hole_id|set_id|default_placement_role_id|
----+---------+-------+------+-------------------------+
1073|        1|   1134|     1|                       13|
1074|        1|   1136|     1|                       13|
1075|        1|   1138|     1|                       13|
1076|        1|   1140|     1|                       13|
1077|        1|   1142|     1|                       13|
 * 
 * Tells us which layout, which hole, and which set. Also default_placement_role_id. So placement_roles next.
 * 
 */

SELECT * FROM placement_roles WHERE product_id=1;
/*
id|product_id|position|name  |full_name|led_color|screen_color|
--+----------+--------+------+---------+---------+------------+
12|         1|       1|start |Start    |00FF00   |00DD00      |
13|         1|       2|middle|Middle   |00FFFF   |00FFFF      |
14|         1|       3|finish|Finish   |FF00FF   |FF00FF      |
15|         1|       4|foot  |Foot Only|FFA500   |FFA500      |
 * 
 * Tells us the role of placements. Will be useful when unpacking the `frames` feature of a climb.
 * 
 */

/*
 * 
 */

SELECT * FROM holes;
/*
id  |product_id|name  |x  |y|mirrored_hole_id|mirror_group|
----+----------+------+---+-+----------------+------------+
1133|         1|35,KB1|140|4|               0|           0|
1134|         1|34,KB2|136|8|               0|           0|
1135|         1|33,KB1|132|4|               0|           0|
1136|         1|32,KB2|128|8|               0|           0|
1137|         1|31,KB1|124|4|               0|           0|
 * 
 * These tell us the coordinates on the board.
 * 
 * Lastly, let's look at leds.
 */


SELECT * FROM leds WHERE product_size_id=28;
/*
id  |product_size_id|hole_id|position|
----+---------------+-------+--------+
9559|             28|   4381|       0|
9560|             28|   4357|       1|
9561|             28|   4380|       2|
9562|             28|   4338|       3|
9563|             28|   4379|       4|
 * 
 * just tells us which led goes to which hole. 
 * 
 */


-------------------------------------
/*
 * STRAGGLERS
 * 
 * Let's take a look at the rest of the non-empty tables that are left over. 
 */

SELECT * FROM beta_links;
/*
climb_uuid                      |link                                    |foreign_username|angle|thumbnail                                                              |is_listed|created_at                |
--------------------------------+----------------------------------------+----------------+-----+-----------------------------------------------------------------------+---------+--------------------------+
00045F0E6F0340ACAE7CF216E1055B8B|https://www.instagram.com/p/CYeDgWJIJac/|ahharreh        |     |https://api.kilterboardapp.com/img/beta_link_thumbnails/CYeDgWJIJac.jpg|        1|2022-01-19 20:32:12.844835|
00079a6f946b4c26ba25123f77f41ea8|https://www.instagram.com/p/CWjXMKHgcRe/|eh_kilterboard  |     |https://api.kilterboardapp.com/img/beta_link_thumbnails/CWjXMKHgcRe.jpg|        1|2021-12-03 18:35:46.977820|
001706160DE64AF2B5550E81418D2DB9|https://www.instagram.com/p/CbBRRpED8tX/|nogoodkilter    |   40|https://api.kilterboardapp.com/img/beta_link_thumbnails/CbBRRpED8tX.jpg|        1|2022-03-17 19:05:44.698980|
001BB37F792645D08BD8001EAF839FAE|https://www.instagram.com/p/CaoZiuZjInX/|hangbored       |   40|https://api.kilterboardapp.com/img/beta_link_thumbnails/CaoZiuZjInX.jpg|        1|2022-03-17 19:05:47.874576|
001BB37F792645D08BD8001EAF839FAE|https://www.instagram.com/p/CPXy4wYDIRk/|georgeli_       |     |https://api.kilterboardapp.com/img/beta_link_thumbnails/CPXy4wYDIRk.jpg|        1|2021-06-03 01:50:43.405564|
 * 
 * Yep, just insta links.
 */

SELECT * FROM attempts;
/*
id|position|name     |
--+--------+---------+
 1|       1|Flash    |
 2|       2|2 tries  |
 3|       3|3 tries  |
 4|       4|4 tries  |
 5|       5|5 tries  |
 6|       6|6 tries  |
 7|       7|7 tries  |
 8|       8|8 tries  |
 9|       9|9 tries  |
10|      10|10 tries |
11|     100|1 day    |
12|     200|2 days   |
13|     300|3 days   |
14|     400|4 days   |
15|     500|5 days   |
16|     600|6 days   |
17|     700|7 days   |
18|     800|8 days   |
19|     900|9 days   |
20|    1000|10 days  |
21|   10000|1 month  |
22|   20000|2 months |
23|   30000|3 months |
24|   40000|4 months |
25|   50000|5 months |
26|   60000|6 months |
27|   70000|7 months |
28|   80000|8 months |
29|   90000|9 months |
30|  100000|10 months|
31|  110000|11 months|
32|  120000|12 months|
33| 1000000|1 year   |
34| 2000000|2 years  |
35| 3000000|3 years  |
36| 4000000|4 years  |
37| 5000000|5 years  |
 0|       0|Unknown  |
 * 
 * doesn't say much
 */

SELECT * FROM kits;
/*
serial_number|name                   |is_autoconnect|is_listed|created_at                |updated_at                |
-------------+-----------------------+--------------+---------+--------------------------+--------------------------+
75466        |Kilter Board Homewall  |             0|        1|2021-04-25 20:26:34.907145|2021-04-25 20:26:34.907145|
75491        |Illyria Kilter Wall    |             1|        1|2021-04-15 16:13:55.430705|2021-04-15 16:40:39.774168|
75546        |16x12 Original         |             0|        1|2021-04-21 21:03:55.249814|2021-04-21 21:03:55.249814|
75586        |Kilter Board 50 Degrees|             0|        1|2021-09-21 17:19:41.134610|2021-09-21 17:19:41.134610|
75587        |Kilter Board 30 Degrees|             0|        1|2021-09-21 17:19:41.250711|2021-09-21 17:19:41.250711|
 * 
 * 
 * and so on. Just contains serial number info and some other info
 */

SELECT * FROM shared_syncs;
/*
table_name                |last_synchronized_at      |
--------------------------+--------------------------+
gyms                      |2021-11-01 21:39:02.287083|
boards                    |2021-11-01 21:39:02.287083|
attempts                  |2024-06-22 23:41:31.475997|
products                  |2024-06-22 23:41:31.475997|
product_sizes             |2024-06-22 23:41:31.475997|
holes                     |2024-06-22 23:41:31.475997|
leds                      |2024-06-22 23:41:31.475997|
sets                      |2024-06-22 23:41:31.475997|
products_angles           |2024-06-22 23:41:31.475997|
layouts                   |2024-06-22 23:41:31.475997|
product_sizes_layouts_sets|2024-06-22 23:41:31.475997|
placement_roles           |2024-06-22 23:41:31.475997|
placements                |2024-06-22 23:41:31.475997|
climbs                    |2026-01-31 01:19:49.420866|
climb_stats               |2026-01-31 01:20:45.147249|
beta_links                |2026-01-09 03:16:03.515955|
kits                      |2025-12-25 16:24:58.083835|
 */

SELECT * FROM android_metadata;
/*
locale|
------+
en_US |
 * Nothing here.
 */


----------------------------------------------------------------------------------------
/*
 * UNDERSTANDING MORE
 * 
 * Let's start with understanding more about layouts and placements.
 */

-- How many climbs per layout? What about stats?
SELECT
    c.layout_id,
    COUNT(DISTINCT c.uuid) AS climbs,
    COUNT(cs.climb_uuid) AS stats_rows
FROM climbs c
LEFT JOIN climb_stats cs ON c.uuid = cs.climb_uuid
GROUP BY c.layout_id;
/*
layout_id|climbs|stats_rows|
---------+------+----------+
        1|315357|    302510|
        2|   160|       154|
        3|     2|         0|
        5|   637|       438|
        6|     6|         2|
        7|    12|        11|
        8| 28330|     44899|
 */

-- How many placements per layout?
SELECT
    layout_id,
    COUNT(*) AS placement_count
FROM placements
GROUP BY layout_id;
/*
layout_id|placement_count|
---------+---------------+
        1|            692|
        2|            472|
        3|              5|
        4|            409|
        5|            544|
        6|            673|
        7|            479|
        8|            499|
 */

-- How do sets relate to the layout?
SELECT
    l.id AS layout_id,
    l.name AS layout_name,
    p.set_id,
    s.name AS set_name,
    COUNT(p.id) AS placement_count
FROM layouts l
JOIN placements p ON l.id = p.layout_id
JOIN sets s ON p.set_id = s.id
GROUP BY l.id, l.name, p.set_id, s.name
ORDER BY l.id, p.set_id;
/*
layout_id|layout_name          |set_id|set_name           |placement_count|
---------+---------------------+------+-------------------+---------------+
        1|Kilter Board Original|     1|Bolt Ons           |            488|
        1|Kilter Board Original|    20|Screw Ons          |            204|
        2|JUUL                 |    21|JUUL All           |            472|
        3|Standard Medium      |    22|Demo Holds         |              5|
        4|BKBBoard Level 1     |    23|BKB All            |            409|
        5|Spire                |    24|Spire All          |            544|
        6|Tycho Complete       |    25|Orbit              |            673|
        7|Tycho 2020           |    25|Orbit              |            479|
        8|Kilter Board Homewall|    26|Mainline           |            234|
        8|Kilter Board Homewall|    27|Auxiliary          |            238|
        8|Kilter Board Homewall|    28|Mainline Kickboard |             13|
        8|Kilter Board Homewall|    29|Auxiliary Kickboard|             14|
 *
 * So 288 + 204 = 692 placements for our big board
 */

-- Where do the placements go?
SELECT
    p.id AS placement_id,
    p.layout_id,
    l.name AS layout_name,
    p.hole_id,
    h.name AS hole_name,
    h.x,
    h.y,
    s.name AS set_name
FROM placements p
JOIN holes h ON p.hole_id = h.id
JOIN sets s ON p.set_id = s.id
JOIN layouts l ON p.layout_id = l.id
ORDER BY p.layout_id, p.id;
/*
placement_id|layout_id|layout_name          |hole_id|hole_name|x  |y|set_name|
------------+---------+---------------------+-------+---------+---+-+--------+
        1073|        1|Kilter Board Original|   1134|34,KB2   |136|8|Bolt Ons|
        1074|        1|Kilter Board Original|   1136|32,KB2   |128|8|Bolt Ons|
        1075|        1|Kilter Board Original|   1138|30,KB2   |120|8|Bolt Ons|
        1076|        1|Kilter Board Original|   1140|28,KB2   |112|8|Bolt Ons|
        1077|        1|Kilter Board Original|   1142|26,KB2   |104|8|Bolt Ons|
 */

-- How many LEDs total, and by product_size?
SELECT
    ps.id AS product_size_id,
    ps.name AS size_name,
    p.name AS product_name,
    COUNT(l.id) AS led_count
FROM leds l
JOIN product_sizes ps ON l.product_size_id = ps.id
JOIN products p ON ps.product_id = p.id
GROUP BY ps.id, ps.name, p.name
ORDER BY ps.id;
/*
product_size_id|size_name                |product_name         |led_count|
---------------+-------------------------+---------------------+---------+
              7|12 x 14                  |Kilter Board Original|      527|
              8|8 x 12                   |Kilter Board Original|      311|
             10|12 x 12 with kickboard   |Kilter Board Original|      476|
             11|Full Wall                |JUUL                 |      472|
             12|5 Holds                  |Demo Board           |        5|
             13|10 x 10                  |BKB Board            |      344|
             14|7 x 10                   |Kilter Board Original|      225|
             15|Spire                    |Spire                |      544|
             16|Full                     |Tycho                |      673|
             17|7x10                     |Kilter Board Homewall|      305|
             18|7x10                     |Kilter Board Homewall|      165|
             19|7x10                     |Kilter Board Homewall|      140|
             20|10 x 12                  |BKB Board            |      409|
             21|10x10                    |Kilter Board Homewall|      391|
             22|10x10                    |Kilter Board Homewall|      195|
             23|8x12                     |Kilter Board Homewall|      389|
             24|8x12                     |Kilter Board Homewall|      219|
             25|10x12                    |Kilter Board Homewall|      499|
             26|10x12                    |Kilter Board Homewall|      261|
             27|12 x 12 without kickboard|Kilter Board Original|      441|
             28|16 x 12                  |Kilter Board Original|      641|
             29|10x10                    |Kilter Board Homewall|      196|
 *
 * So we have 641 LEDs for the 16x14
 *
 */

-- Check if every hole has an LED
SELECT
    COUNT(DISTINCT h.id) AS total_holes,
    COUNT(DISTINCT l.hole_id) AS holes_with_leds,
    COUNT(DISTINCT h.id) - COUNT(DISTINCT l.hole_id) AS holes_without_leds
FROM holes h
LEFT JOIN leds l ON h.id = l.hole_id;
/*
 *
total_holes|holes_with_leds|holes_without_leds|
-----------+---------------+------------------+
       3294|           3294|                 0|
 */

SELECT COUNT(DISTINCT p.hole_id) AS holes_in_layout_1
FROM placements p
WHERE p.layout_id = 1;
/*
holes_in_layout_1|
-----------------+
              692|
 *
 * adds up with our number of placements
 */

-- What's the hole range for each product?
SELECT
    h.product_id,
    MIN(h.id) AS min_hole_id,
    MAX(h.id) AS max_hole_id,
    COUNT(*) AS total_holes
FROM holes h
GROUP BY h.product_id;
/*
product_id|min_hole_id|max_hole_id|total_holes|
----------+-----------+-----------+-----------+
         1|       1133|       4426|        692|
         2|       1660|       2131|        472|
         3|       2132|       2136|          5|
         4|       2137|       4067|        409|
         5|       2481|       3024|        544|
         6|       3025|       3697|        673|
         7|       3698|       4261|        499|
*/

-- Do LED positions overlap or are they sequential per size?
SELECT
    product_size_id,
    MIN(position) AS min_pos,
    MAX(position) AS max_pos,
    COUNT(*) AS led_count
FROM leds
GROUP BY product_size_id
ORDER BY product_size_id;
/*
product_size_id|min_pos|max_pos|led_count|
---------------+-------+-------+---------+
              7|      0|    527|      527|
              8|      0|    311|      311|
             10|      0|    476|      476|
             11|      0|    471|      472|
             12|      0|      4|        5|
             13|      0|    344|      344|
             14|      0|    224|      225|
             15|      0|    546|      544|
             16|      0|    673|      673|
             17|      0|    304|      305|
             18|      0|    164|      165|
             19|      0|    139|      140|
             20|      0|    409|      409|
             21|      0|    390|      391|
             22|      0|    194|      195|
             23|      0|    389|      389|
             24|      0|    219|      219|
             25|      0|    499|      499|
             26|      0|    261|      261|
             27|      0|    440|      441|
             28|      0|    641|      641|
             29|      0|    195|      196|
 * 
 */

-- Which holes in the KBO range (1133-4426) are NOT used by layout 10?
SELECT *
FROM holes h
WHERE h.product_id = 1
AND h.id NOT IN (
    SELECT DISTINCT p.hole_id
    FROM placements p
    WHERE p.layout_id = 1
);
/*
id|product_id|name|x|y|mirrored_hole_id|mirror_group|
--+----------+----+-+-+----------------+------------+
 */

---------------------------------------------------------------
/*
 * So we understand HOW the board works pretty well now. Let's summarize.
 * - There are about 350k climbs, across a bunch of layouts
 * - There are a similar amount of statistics for climbs. This includes multiple angles for each climb.
 * - Some key features are the frames, the angle, and the layout_id (the latter determines the board, the former the actual climb on the board)
 * - Hold positions are decoded via mapping placements to (x,y) coordinates (from the holes tables)
 * - There are four hold types: start, middle, finish, foot. 692 holds on the Original (16x12)
 */




