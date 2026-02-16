/*
 * main.c - Battleship Game Main Program
 * Cross-platform: Windows (MSVC/MinGW) and UNIVAC 1219 (GCC)
 * 
 * Implements Battleship game with Intermediate Adversary AI
 * Uses XorShift RNG seeded with time(0) for UNIVAC compatibility
 */

#include "battleship.h"

int main(int argc, char* argv[]) {
    Player human;
    Player ai_player;
    IntermediateAI ai_engine;
    unsigned int rng_state;
    char input[100];
    char shot[MAX_COORD_LENGTH];
    char shot_row;
    int shot_col;
    int i;
    int did_p1_win = 0;
    
    printf("\n========================================\n");
    printf("   BATTLESHIP - Intermediate AI\n");
    printf("   Platform: %s\n", PLATFORM_NAME);
    printf("========================================\n\n");
    
    /* Initialize random number generator */
    init_random(&rng_state);
    
    /* Menu 1: Action Menu */
    printf("What would you like to do?\n");
    printf("\t[s]tart\n\te[x]it\n");
    get_input(input, sizeof(input));
    
    if (input[0] == 'x' || input[0] == 'X') {
        printf("Exiting game. Goodbye!\n");
        return 0;
    }
    
    /* Get human player name */
    printf("\nEnter your name: ");
    get_input(input, sizeof(input));
    init_player(&human, input);
    
    /* Initialize AI player */
    init_player(&ai_player, "Intermediate AI");
    init_intermediate_ai(&ai_engine);
    
    printf("\n========================================\n");
    printf("   GAME SETUP\n");
    printf("========================================\n\n");
    
    /* Human places ships */
    printf("Player 1, place your ships on the game field\n");
    print_battlefield(&human.arena, 0);
    
    for (i = 0; i < NO_OF_SHIPS; i++) {
        char roF, roS;
        int coF, coS;
        int placement_res;
        
        printf("\nPlace %s (length %d)\n", human.ships[i].name, human.ships[i].length);
        printf("Enter first coordinate (e.g., A1): ");
        get_input(input, sizeof(input));
        roF = input[0];
        #ifdef _MSC_VER
        sscanf_s(input + 1, "%d", &coF);
        #else
        sscanf(input + 1, "%d", &coF);
        #endif
        
        printf("Enter second coordinate (e.g., A5): ");
        get_input(input, sizeof(input));
        roS = input[0];
        #ifdef _MSC_VER
        sscanf_s(input + 1, "%d", &coS);
        #else
        sscanf(input + 1, "%d", &coS);
        #endif
        
        /* Normalize coordinates */
        normalize_coordinates(&roF, &roS, &coF, &coS);
        
        /* Validate placement */
        placement_res = is_correct_coordinates(&human.arena, roF, roS, coF, coS, &human.ships[i]);
        
        if (placement_res != VALID_COORD) {
            printf("Invalid placement! Try again.\n");
            i--;
            continue;
        }
        
        /* Place ship on battlefield */
        if (roF == roS) {
            int j;
            for (j = coF; j <= coS; j++) {
                place_piece(&human.arena, roF, j, SHIP_PIECE);
            }
        } else {
            char j;
            for (j = roF; j <= roS; j++) {
                place_piece(&human.arena, j, coF, SHIP_PIECE);
            }
        }
        
        store_ship_placement(&human.ships[i], roF, roS, coF, coS);
        print_battlefield(&human.arena, 0);
    }
    
    prompt_enter_key();
    
    /* AI places ships */
    printf("\nKindly wait while the machine places its ships\n");
    for (i = 0; i < NO_OF_SHIPS; i++) {
        ai_place_ship(&ai_player, i, &rng_state);
    }
    printf("\nThe machine has completed placing its ships!\n\n");
    print_battlefield(&ai_player.arena, 0);
    
    prompt_enter_key();
    
    /* Wartime - Main game loop */
    printf("The game starts!\n\n");
    
    while (1) {
        /* Display both battlefields */
        printf("Enemy battlefield:\n");
        print_battlefield(&ai_player.arena, 1);
        print_divider();
        printf("Your battlefield:\n");
        print_battlefield(&human.arena, 0);
        
        /* Human fires */
        printf("Enter coordinates to fire at (e.g., B5): ");
        get_input(input, sizeof(input));
        SAFE_STRCPY(shot, input, MAX_COORD_LENGTH);
        shot_row = shot[0];
        #ifdef _MSC_VER
        sscanf_s(shot + 1, "%d", &shot_col);
        #else
        sscanf(shot + 1, "%d", &shot_col);
        #endif
        
        /* Process human shot */
        if (is_hit(&ai_player.arena, shot_row, shot_col)) {
            ai_manage_ship_hit(&ai_player, &ai_engine, shot_row, shot_col);
        } else if (is_miss(&ai_player.arena, shot_row, shot_col)) {
            place_piece(&ai_player.arena, shot_row, shot_col, MISS);
            printf("You missed! Try again next turn\n");
        } else {
            printf("Already fired at this location!\n");
        }
        
        /* Check if human won */
        if (is_navy_sunken(&ai_player)) {
            did_p1_win = 1;
            break;
        }
        
        /* AI fires */
        printf("\nPlease wait while the engine makes its move\n");
        ai_fire_salvo(&ai_engine, shot, &rng_state);
        printf("The engine fired at %s\n", shot);
        shot_row = shot[0];
        #ifdef _MSC_VER
        sscanf_s(shot + 1, "%d", &shot_col);
        #else
        sscanf(shot + 1, "%d", &shot_col);
        #endif
        
        /* Process AI shot */
        if (is_hit(&human.arena, shot_row, shot_col)) {
            manage_ship_hit(&human, shot_row, shot_col);
        } else if (is_miss(&human.arena, shot_row, shot_col)) {
            place_piece(&human.arena, shot_row, shot_col, MISS);
            printf("The engine fired at %s and missed.\n", shot);
        }
        
        /* Check if AI won */
        if (is_navy_sunken(&human)) {
            break;
        }
        
        printf("\n");
    }
    
    /* Game end */
    printf("\n========================================\n");
    printf("   GAME OVER\n");
    printf("========================================\n\n");
    
    if (did_p1_win) {
        printf("Congratulations %s, you have won this game of Battleship!\n", human.name);
    } else {
        printf("The Intermediate AI Engine won this game of Battleship!\n");
    }
    
    return 0;
}
