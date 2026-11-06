# Exercise filming guide

How to film the 114 exercise clips for BMI Health with a phone, at no cost. Each clip replaces that exercise's animated guide in the app; any exercise without a clip keeps its animation, so you can film in any order and add clips a few at a time.

## What you need

- A phone that records 1080p (any recent phone).
- A tripod or a steady shelf at about hip height.
- A plain wall or uncluttered gym corner, with even light. Avoid filming toward a bright window.
- Two demonstrators: one male and one female (the app shows the one matching the user's choice). If you only have one, film that one first; the app uses the other trainer's clip as a fallback.
- Gym equipment for the gym exercises. 52 of the 114 need only body weight or a resistance band.

## Rules for every clip

1. **Landscape (sideways) orientation**, phone not moving, whole body and equipment in frame with a little space around.
2. **Camera angle from the table below.** *Side*: the camera looks at the demonstrator's left side, so they face the right of the screen, the same as the animation. *Front*: the camera faces the demonstrator.
3. **Length 8–10 seconds**: two or three clean reps at a steady speed (about 2 seconds down, 1–2 seconds up). For holds such as the plank, hold for 8 seconds. Anything after 10 seconds is cut off.
4. **No talking, music or text** in the clip. The sound is removed; the app adds its own voice cues.
5. **Correct form only.** A qualified trainer should check each clip before it is added. Retake any rep with a mistake listed on the exercise's page.
6. **Fitted, plain clothes** with no logos or brand names, so joints are easy to see. Closed shoes.
7. **Nobody else in frame**, no faces of other gym members, no recognisable gym branding.

## Naming the files

Name each file `<id>_male` or `<id>_female` with any video extension (`.mp4`, `.mov`, `.m4v`), using the id from the table. Example: `barbell_bench_press_female.mov`. A file with any other name is skipped and listed when you add clips.

## Adding clips to the app

Put the files in one folder and run one of these from the project folder. Each clip is trimmed to 10 seconds, silenced, scaled to 720p and compressed (needs the free tool ffmpeg: `brew install ffmpeg`).

**Option A: inside the app.** Simplest. Each clip adds about 0.5–1 MB to the download, so all 228 clips would add roughly 150 MB.

```
python3 -I tool/videos/add_videos.py ~/Desktop/clips --bundle
```

**Option B: free hosting.** Keeps the app small. Put the clips online free (for example a public GitHub repository with GitHub Pages turned on), then:

```
python3 -I tool/videos/add_videos.py ~/Desktop/clips --base-url https://YOUR-NAME.github.io/bmi-videos
```

and upload everything in `build/exercise_videos/` to that address. The app streams a clip the first time and keeps it on the phone afterwards, so it then works offline. Until a clip has downloaded, and whenever it can't play, the app shows the animation.

Rebuild the app after adding clips. The tool prints how many of the 114 exercises have a video.

## Shot list

Film the most-used exercises first: Home Challenges and the Muscle day picks rely mostly on body-weight moves (push-ups, squats, lunges, planks, glute bridges, jumping jacks and the stretches).

### Chest

| # | Exercise | Files | Camera | Show |
|---|---|---|---|---|
| 1 | Barbell Bench Press | `barbell_bench_press_male.mp4`<br>`barbell_bench_press_female.mp4` | Side | Lie on the bench with eyes under the bar and feet flat on the floor; press the bar back up until your arms are straight |
| 2 | Incline Barbell Bench Press | `incline_barbell_bench_press_male.mp4`<br>`incline_barbell_bench_press_female.mp4` | Side | Set the bench to 30–45° and lie back with feet flat; press it back up over your shoulders |
| 3 | Decline Bench Press | `decline_bench_press_male.mp4`<br>`decline_bench_press_female.mp4` | Side | Lie on a decline bench with your legs secured under the pads; press it back up until your arms are straight |
| 4 | Dumbbell Bench Press | `dumbbell_bench_press_male.mp4`<br>`dumbbell_bench_press_female.mp4` | Side | Sit on the bench with a dumbbell on each thigh, then lie back; press them up and slightly together |
| 5 | Incline Dumbbell Press | `incline_dumbbell_press_male.mp4`<br>`incline_dumbbell_press_female.mp4` | Side | Set the bench to about 30°; lower under control |
| 6 | Dumbbell Fly | `dumbbell_fly_male.mp4`<br>`dumbbell_fly_female.mp4` | Side | Lie on a flat bench holding dumbbells above your chest, palms facing each other; bring the dumbbells back together in an arc |
| 7 | Chest Press Machine | `chest_press_machine_male.mp4`<br>`chest_press_machine_female.mp4` | Side | Adjust the seat so the handles are at mid-chest height; return slowly until you feel a stretch in your chest |
| 8 | Pec Deck | `pec_deck_male.mp4`<br>`pec_deck_female.mp4` | Front | Adjust the seat so the handles are at chest height; open slowly back to the start |
| 9 | Cable Fly | `cable_fly_male.mp4`<br>`cable_fly_female.mp4` | Front | Set both pulleys at shoulder height and step forward; return slowly |
| 10 | Low-to-High Cable Fly | `low_to_high_cable_fly_male.mp4`<br>`low_to_high_cable_fly_female.mp4` | Front | Set both pulleys at the lowest position; lower back down slowly |
| 11 | Push-up | `push_up_male.mp4`<br>`push_up_female.mp4` | Side | Hands slightly wider than shoulders, body in a straight line; push back up to straight arms |
| 12 | Incline Push-up | `incline_push_up_male.mp4`<br>`incline_push_up_female.mp4` | Side | Place your hands on a bench, table or wall, slightly wider than your shoulders; push back to straight arms |
| 13 | Knee Push-up | `knee_push_up_male.mp4`<br>`knee_push_up_female.mp4` | Side | Start on hands and knees, hands under shoulders; push back up |
| 14 | Chest Dip | `chest_dip_male.mp4`<br>`chest_dip_female.mp4` | Side | Support yourself on parallel bars with straight arms; push back up |
| 15 | Band Chest Press | `band_chest_press_male.mp4`<br>`band_chest_press_female.mp4` | Side | Anchor the band behind you at chest height; return slowly against the band |
| 16 | Doorway Chest Stretch | `chest_doorway_stretch_male.mp4`<br>`chest_doorway_stretch_female.mp4` | Side | Stand in a doorway with forearms on the frame, elbows at shoulder height; breathe slowly and hold |

### Back

| # | Exercise | Files | Camera | Show |
|---|---|---|---|---|
| 17 | Barbell Deadlift | `barbell_deadlift_male.mp4`<br>`barbell_deadlift_female.mp4` | Side | Stand with the bar over mid-foot, feet hip-width apart; lower the bar by hinging at the hips first |
| 18 | Barbell Row | `barbell_row_male.mp4`<br>`barbell_row_female.mp4` | Side | Hold the bar with hands just wider than your hips; lower it under control |
| 19 | T-Bar Row | `t_bar_row_male.mp4`<br>`t_bar_row_female.mp4` | Side | Straddle the bar with a V-handle under the plates; lower slowly |
| 20 | Pull-up | `pull_up_male.mp4`<br>`pull_up_female.mp4` | Side | Hang from the bar with hands slightly wider than shoulders; lower all the way down with control |
| 21 | Chin-up | `chin_up_male.mp4`<br>`chin_up_female.mp4` | Side | Hang from the bar with palms facing you, hands shoulder-width; lower all the way down |
| 22 | Assisted Pull-up | `assisted_pull_up_male.mp4`<br>`assisted_pull_up_female.mp4` | Side | Choose the assistance weight and kneel or stand on the platform; lower slowly to straight arms |
| 23 | Lat Pulldown | `lat_pulldown_male.mp4`<br>`lat_pulldown_female.mp4` | Side | Sit with thighs under the pads and grip the bar wide; let the bar rise slowly |
| 24 | Seated Cable Row | `seated_cable_row_male.mp4`<br>`seated_cable_row_female.mp4` | Side | Sit tall with knees slightly bent; extend your arms slowly |
| 25 | Machine Row | `machine_row_male.mp4`<br>`machine_row_female.mp4` | Side | Adjust the chest pad so you can just reach the handles; return slowly |
| 26 | One-arm Dumbbell Row | `dumbbell_row_male.mp4`<br>`dumbbell_row_female.mp4` | Side | Place one knee and hand on a bench, back flat; lower slowly and repeat, then switch sides |
| 27 | Straight-arm Pulldown | `straight_arm_pulldown_male.mp4`<br>`straight_arm_pulldown_female.mp4` | Side | Set the cable high and hold the bar with straight arms; let it rise slowly |
| 28 | Inverted Row | `inverted_row_male.mp4`<br>`inverted_row_female.mp4` | Side | Lie under a bar set at waist height (or a sturdy table); lower slowly |
| 29 | Back Extension | `back_extension_male.mp4`<br>`back_extension_female.mp4` | Side | Set the pad just below your hips on a back-extension bench; raise back up until your body is straight, not past it |
| 30 | Band Row | `resistance_band_row_male.mp4`<br>`resistance_band_row_female.mp4` | Side | Anchor the band at chest height; return slowly |
| 31 | Cat-Cow | `cat_cow_male.mp4`<br>`cat_cow_female.mp4` | Side | Start on hands and knees; keep flowing slowly between the two |
| 32 | Child's Pose | `childs_pose_male.mp4`<br>`childs_pose_female.mp4` | Side | Kneel and sit back on your heels; breathe deeply into your back |

### Shoulders

| # | Exercise | Files | Camera | Show |
|---|---|---|---|---|
| 33 | Overhead Press | `overhead_press_male.mp4`<br>`overhead_press_female.mp4` | Side | Hold the bar at shoulder height, grip just outside your shoulders; lower it back to your shoulders |
| 34 | Dumbbell Shoulder Press | `dumbbell_shoulder_press_male.mp4`<br>`dumbbell_shoulder_press_female.mp4` | Side | Sit or stand with dumbbells at shoulder height; lower slowly to shoulder level |
| 35 | Machine Shoulder Press | `machine_shoulder_press_male.mp4`<br>`machine_shoulder_press_female.mp4` | Side | Adjust the seat so the handles start at shoulder height; lower slowly |
| 36 | Arnold Press | `arnold_press_male.mp4`<br>`arnold_press_female.mp4` | Side | Sit holding dumbbells in front of your shoulders, palms facing you; reverse the movement on the way down |
| 37 | Lateral Raise | `lateral_raise_male.mp4`<br>`lateral_raise_female.mp4` | Front | Stand with dumbbells at your sides; lower slowly |
| 38 | Cable Lateral Raise | `cable_lateral_raise_male.mp4`<br>`cable_lateral_raise_female.mp4` | Front | Set the cable low and stand side-on to the machine; lower slowly, then switch sides |
| 39 | Front Raise | `front_raise_male.mp4`<br>`front_raise_female.mp4` | Side | Stand with dumbbells in front of your thighs; lower slowly |
| 40 | Rear Delt Fly | `rear_delt_fly_male.mp4`<br>`rear_delt_fly_female.mp4` | Side | Hinge forward with a flat back, dumbbells hanging below your chest; lower slowly |
| 41 | Face Pull | `face_pull_male.mp4`<br>`face_pull_female.mp4` | Side | Set a rope on the cable at face height; return slowly |
| 42 | Band Pull-apart | `band_pull_apart_male.mp4`<br>`band_pull_apart_female.mp4` | Front | Hold a band in front of you at shoulder height, arms straight; return slowly |
| 43 | Pike Push-up | `pike_push_up_male.mp4`<br>`pike_push_up_female.mp4` | Side | Start in a push-up position, then walk your feet in so your hips point up; push back up |
| 44 | Cross-body Shoulder Stretch | `cross_body_shoulder_stretch_male.mp4`<br>`cross_body_shoulder_stretch_female.mp4` | Front | Bring one arm straight across your chest; hold, then switch arms |

### Biceps

| # | Exercise | Files | Camera | Show |
|---|---|---|---|---|
| 45 | Barbell Curl | `barbell_curl_male.mp4`<br>`barbell_curl_female.mp4` | Side | Stand holding the bar with palms facing forward; lower slowly |
| 46 | Dumbbell Curl | `dumbbell_curl_male.mp4`<br>`dumbbell_curl_female.mp4` | Side | Stand with dumbbells at your sides, palms forward; squeeze at the top and lower slowly |
| 47 | Hammer Curl | `hammer_curl_male.mp4`<br>`hammer_curl_female.mp4` | Side | Stand with dumbbells at your sides, palms facing your body; lower slowly |
| 48 | Incline Dumbbell Curl | `incline_dumbbell_curl_male.mp4`<br>`incline_dumbbell_curl_female.mp4` | Side | Sit back on a bench set to about 60°, arms hanging straight down; lower all the way to a full stretch |
| 49 | Preacher Curl | `preacher_curl_male.mp4`<br>`preacher_curl_female.mp4` | Side | Sit at a preacher bench with the backs of your arms on the pad; lower slowly until your arms are almost straight |
| 50 | Cable Curl | `cable_curl_male.mp4`<br>`cable_curl_female.mp4` | Side | Attach a straight bar to a low cable; lower slowly |
| 51 | Concentration Curl | `concentration_curl_male.mp4`<br>`concentration_curl_female.mp4` | Side | Sit on a bench and rest the back of your upper arm on your inner thigh; lower slowly, then switch arms |
| 52 | Band Curl | `band_curl_male.mp4`<br>`band_curl_female.mp4` | Side | Stand on the middle of a band, ends in your hands; lower slowly |

### Triceps

| # | Exercise | Files | Camera | Show |
|---|---|---|---|---|
| 53 | Tricep Pushdown | `tricep_pushdown_male.mp4`<br>`tricep_pushdown_female.mp4` | Side | Hold the bar or rope at chest height, elbows by your sides; return slowly without moving your elbows |
| 54 | Overhead Tricep Extension | `overhead_tricep_extension_male.mp4`<br>`overhead_tricep_extension_female.mp4` | Side | Sit tall and hold one dumbbell overhead with both hands; straighten your arms to lift it back up |
| 55 | Overhead Cable Extension | `overhead_cable_extension_male.mp4`<br>`overhead_cable_extension_female.mp4` | Side | Attach a rope to a low or mid cable and face away from the machine; return slowly |
| 56 | Skull Crusher | `skull_crusher_male.mp4`<br>`skull_crusher_female.mp4` | Side | Lie on a bench holding an EZ-bar above your chest, arms straight; straighten your arms to lift it back |
| 57 | Close-grip Bench Press | `close_grip_bench_press_male.mp4`<br>`close_grip_bench_press_female.mp4` | Side | Lie on a bench and grip the bar about shoulder-width apart; press back up |
| 58 | Tricep Kickback | `tricep_kickback_male.mp4`<br>`tricep_kickback_female.mp4` | Side | Hinge forward with one hand on a bench, dumbbell in the other; bend it slowly to return |
| 59 | Bench Dip | `bench_dip_male.mp4`<br>`bench_dip_female.mp4` | Side | Sit on a bench edge with hands next to your hips; push back up |
| 60 | Diamond Push-up | `diamond_push_up_male.mp4`<br>`diamond_push_up_female.mp4` | Side | Start in a push-up with your hands together under your chest, fingers forming a diamond; push back up |

### Quads

| # | Exercise | Files | Camera | Show |
|---|---|---|---|---|
| 61 | Barbell Back Squat | `barbell_back_squat_male.mp4`<br>`barbell_back_squat_female.mp4` | Side | Rest the bar on your upper back, feet shoulder-width apart; drive back up through your whole foot |
| 62 | Front Squat | `front_squat_male.mp4`<br>`front_squat_female.mp4` | Side | Rest the bar on the front of your shoulders, elbows high; drive back up, elbows staying high |
| 63 | Goblet Squat | `goblet_squat_male.mp4`<br>`goblet_squat_female.mp4` | Side | Hold a dumbbell or kettlebell at your chest; stand back up |
| 64 | Bodyweight Squat | `bodyweight_squat_male.mp4`<br>`bodyweight_squat_female.mp4` | Side | Stand with feet shoulder-width apart, arms forward; stand back up |
| 65 | Leg Press | `leg_press_male.mp4`<br>`leg_press_female.mp4` | Side | Sit with your back flat against the pad, feet shoulder-width on the platform; push it back without locking your knees |
| 66 | Hack Squat | `hack_squat_male.mp4`<br>`hack_squat_female.mp4` | Side | Stand on the platform with your back against the pad, shoulders under the pads; push back up through your whole foot |
| 67 | Leg Extension | `leg_extension_male.mp4`<br>`leg_extension_female.mp4` | Side | Sit with the pad on the front of your ankles and knees in line with the pivot; lower slowly |
| 68 | Bulgarian Split Squat | `bulgarian_split_squat_male.mp4`<br>`bulgarian_split_squat_female.mp4` | Side | Stand a big step in front of a bench and rest your back foot on it; push through your front foot to stand, then switch legs |
| 69 | Walking Lunge | `walking_lunge_male.mp4`<br>`walking_lunge_female.mp4` | Side | Step forward and lower until both knees are at about 90°; push off and step into the next lunge |
| 70 | Reverse Lunge | `reverse_lunge_male.mp4`<br>`reverse_lunge_female.mp4` | Side | Stand tall with feet hip-width apart; alternate legs |
| 71 | Step-up | `step_up_male.mp4`<br>`step_up_female.mp4` | Side | Stand in front of a sturdy bench or step, dumbbells at your sides; step down slowly and repeat |
| 72 | Wall Sit | `wall_sit_male.mp4`<br>`wall_sit_female.mp4` | Side | Lean your back against a wall; hold |
| 73 | Jump Squat | `jump_squat_male.mp4`<br>`jump_squat_female.mp4` | Side | Stand with feet shoulder-width apart; land softly and go straight into the next squat |
| 74 | Burpee | `burpee_male.mp4`<br>`burpee_female.mp4` | Side | From standing, squat and place your hands on the floor; jump up with arms overhead |
| 75 | Standing Quad Stretch | `standing_quad_stretch_male.mp4`<br>`standing_quad_stretch_female.mp4` | Side | Stand tall and hold a wall for balance; hold, then switch legs |
| 76 | Kneeling Hip Flexor Stretch | `hip_flexor_stretch_male.mp4`<br>`hip_flexor_stretch_female.mp4` | Side | Kneel on one knee with the other foot in front; hold, then switch sides |
| 77 | High Knees | `high_knees_male.mp4`<br>`high_knees_female.mp4` | Side | Run on the spot; stay light on your feet |
| 78 | Fast March in Place | `march_in_place_male.mp4`<br>`march_in_place_female.mp4` | Side | Stand tall; keep a brisk pace |
| 79 | Squat to Overhead Reach | `squat_to_reach_male.mp4`<br>`squat_to_reach_female.mp4` | Side | Squat down with arms forward; keep moving at a steady pace |

### Hamstrings

| # | Exercise | Files | Camera | Show |
|---|---|---|---|---|
| 80 | Romanian Deadlift | `romanian_deadlift_male.mp4`<br>`romanian_deadlift_female.mp4` | Side | Hold the bar at hip height, knees slightly bent; squeeze your glutes to stand up |
| 81 | Dumbbell Romanian Deadlift | `dumbbell_romanian_deadlift_male.mp4`<br>`dumbbell_romanian_deadlift_female.mp4` | Side | Stand holding dumbbells in front of your thighs; drive your hips forward to stand |
| 82 | Single-leg Romanian Deadlift | `single_leg_rdl_male.mp4`<br>`single_leg_rdl_female.mp4` | Side | Stand on one leg holding a dumbbell in the opposite hand; return to standing, then switch legs |
| 83 | Good Morning | `good_morning_male.mp4`<br>`good_morning_female.mp4` | Side | Rest a light bar on your upper back; drive your hips forward to stand |
| 84 | Lying Leg Curl | `lying_leg_curl_male.mp4`<br>`lying_leg_curl_female.mp4` | Side | Lie face down with the pad just above your heels; lower slowly |
| 85 | Seated Leg Curl | `seated_leg_curl_male.mp4`<br>`seated_leg_curl_female.mp4` | Side | Sit with the pad behind your ankles and the thigh pad locked down; return slowly |
| 86 | Nordic Curl | `nordic_curl_male.mp4`<br>`nordic_curl_female.mp4` | Side | Kneel with your ankles held down by a partner or a pad; catch yourself with your hands and push back up |
| 87 | Seated Hamstring Stretch | `hamstring_stretch_male.mp4`<br>`hamstring_stretch_female.mp4` | Side | Sit with one leg straight and the other foot against your inner thigh; hold, then switch sides |

### Glutes

| # | Exercise | Files | Camera | Show |
|---|---|---|---|---|
| 88 | Hip Thrust | `hip_thrust_male.mp4`<br>`hip_thrust_female.mp4` | Side | Sit with your upper back against a bench and the bar over your hips; lower slowly |
| 89 | Sumo Deadlift | `sumo_deadlift_male.mp4`<br>`sumo_deadlift_female.mp4` | Side | Stand with a wide stance, toes turned out, bar over mid-foot; lower the bar back down under control |
| 90 | Glute Bridge | `glute_bridge_male.mp4`<br>`glute_bridge_female.mp4` | Side | Lie on your back with knees bent and feet flat; lower slowly |
| 91 | Single-leg Glute Bridge | `single_leg_glute_bridge_male.mp4`<br>`single_leg_glute_bridge_female.mp4` | Side | Lie on your back with one foot flat and the other leg straight up; lower slowly, then switch legs |
| 92 | Cable Glute Kickback | `cable_kickback_male.mp4`<br>`cable_kickback_female.mp4` | Side | Attach an ankle strap to a low cable; return slowly, then switch legs |
| 93 | Hip Abduction Machine | `hip_abduction_machine_male.mp4`<br>`hip_abduction_machine_female.mp4` | Front | Sit with the pads on the outside of your knees; return slowly |
| 94 | Banded Lateral Walk | `banded_lateral_walk_male.mp4`<br>`banded_lateral_walk_female.mp4` | Front | Place a mini band just above your knees or around your ankles; take the same number of steps back the other way |
| 95 | Kettlebell Swing | `kettlebell_swing_male.mp4`<br>`kettlebell_swing_female.mp4` | Side | Stand with feet wider than hips, kettlebell in both hands; let it fall back and repeat |
| 96 | Figure-four Glute Stretch | `figure_four_stretch_male.mp4`<br>`figure_four_stretch_female.mp4` | Side | Lie on your back with knees bent; hold, then switch sides |
| 97 | Skater Hop | `skater_hop_male.mp4`<br>`skater_hop_female.mp4` | Front | Hop sideways onto one foot; keep going side to side |

### Calves

| # | Exercise | Files | Camera | Show |
|---|---|---|---|---|
| 98 | Standing Calf Raise | `standing_calf_raise_male.mp4`<br>`standing_calf_raise_female.mp4` | Side | Stand on the edge of a step with heels hanging off; lower your heels below the step |
| 99 | Seated Calf Raise | `seated_calf_raise_male.mp4`<br>`seated_calf_raise_female.mp4` | Side | Sit with the pad on your lower thighs and the balls of your feet on the platform; lower slowly to a stretch |
| 100 | Single-leg Calf Raise | `single_leg_calf_raise_male.mp4`<br>`single_leg_calf_raise_female.mp4` | Side | Stand on one foot on the edge of a step, holding a wall; switch feet after the set |
| 101 | Jumping Jack | `jumping_jack_male.mp4`<br>`jumping_jack_female.mp4` | Front | Stand with feet together, arms by your sides; keep a steady rhythm |
| 102 | Step Jack | `step_jack_male.mp4`<br>`step_jack_female.mp4` | Front | Stand with feet together; alternate sides at a brisk pace |

### Core

| # | Exercise | Files | Camera | Show |
|---|---|---|---|---|
| 103 | Plank | `plank_male.mp4`<br>`plank_female.mp4` | Side | Rest on your forearms and toes; brace your core and hold without letting your hips sag |
| 104 | Side Plank | `side_plank_male.mp4`<br>`side_plank_female.mp4` | Side | Lie on your side, propped on one forearm, elbow under your shoulder; hold, then switch sides |
| 105 | Dead Bug | `dead_bug_male.mp4`<br>`dead_bug_female.mp4` | Side | Lie on your back, arms up and knees bent at 90° above your hips; return and switch sides |
| 106 | Bird Dog | `bird_dog_male.mp4`<br>`bird_dog_female.mp4` | Side | Start on hands and knees, back flat; return and switch sides |
| 107 | Crunch | `crunch_male.mp4`<br>`crunch_female.mp4` | Side | Lie on your back, knees bent, feet flat; lower slowly |
| 108 | Bicycle Crunch | `bicycle_crunch_male.mp4`<br>`bicycle_crunch_female.mp4` | Side | Lie on your back, hands by your head, knees raised; keep it slow and controlled |
| 109 | Russian Twist | `russian_twist_male.mp4`<br>`russian_twist_female.mp4` | Side | Sit with knees bent and lean back slightly, back straight; rotate to the other side |
| 110 | Lying Leg Raise | `leg_raise_male.mp4`<br>`leg_raise_female.mp4` | Side | Lie on your back, hands under your hips, legs straight; lower slowly without arching |
| 111 | Hanging Knee Raise | `hanging_knee_raise_male.mp4`<br>`hanging_knee_raise_female.mp4` | Side | Hang from a pull-up bar with straight arms; lower slowly without swinging |
| 112 | Mountain Climber | `mountain_climber_male.mp4`<br>`mountain_climber_female.mp4` | Side | Start in a push-up position; keep your hips level |
| 113 | Pallof Press | `pallof_press_male.mp4`<br>`pallof_press_female.mp4` | Side | Set a cable at chest height and stand side-on to it; bring it back slowly, then switch sides |
| 114 | Cobra Stretch | `cobra_stretch_male.mp4`<br>`cobra_stretch_female.mp4` | Side | Lie face down with hands under your shoulders; hold and breathe |
