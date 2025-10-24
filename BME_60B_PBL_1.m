% Ian Van Der Linde, Ryan Shabbak, Trevor Holmgren
% 10/21/25
% This script creates a blackjack game

% Create card names for dialogue
cardNames = ["Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10",... % store display names for each rank
    "Jack", "Queen", "King"]; % include face card names

% Create the deck of cards
[deckCards, deckSuits, cardValues] = createDeck(); % call function to build and shuffle deck, returning ranks, suits, and numeric values

% Ask how many are playing
numPlayers = input("Enter number of players (including dealer): "); % ask user for total number of players including dealer
while numPlayers < 2 % ensure there is at least one dealer and one player
    numPlayers = input("Must be at least 2 players: "); % re-prompt if invalid input
end

% Create player and dealer hands
[playerHands, cardIndex] = dealInitialHands(numPlayers, deckCards, deckSuits, cardValues); % deal two cards to each player and dealer

% Show initial hands MAKE SURE TO HIDE DEALER FIRST CARD
for p = numPlayers:-1:1 % loop backwards so dealer (player 1) shows last
    if p == 1 % if current player is the dealer
        fprintf("\nDealer's Hand:\n"); % print header for dealer’s hand
        for c = 1 % first card hidden
            fprintf("%d. Hidden\n", c) % display “Hidden” for dealer’s first card
        end
        for c = 2 % display dealer’s second card
            fprintf("%d. %s of %s \n", c, cardNames(playerHands{p}.cards(c)), ... % print card rank
                playerHands{p}.suits(c)); % print card suit
        end
    else % for all other players
        fprintf("\nPlayer %d's Hand:\n", p); % print header for player’s hand
        for c = 1:2 % show both starting cards
            fprintf("%d. %s of %s \n", c, cardNames(playerHands{p}.cards(c)), ... % print rank
                playerHands{p}.suits(c)); % print suit
        end
    end
end

function [deckCards, deckSuits, cardValues] = createDeck() % function to build shuffled 52-card deck
% This function creates a shuffled deck of cards 
% Create cards and suits
cards = 1:13; % rank numbers 1–13 (1=Ace, 11=Jack, etc.)
suits = ["Spades","Hearts","Diamonds","Clubs"]; % define 4 suits

% Create a grid of 52 cards, numbers 1:13, with assigned suits 1:4
[cardsGrid, suitsGrid] = ndgrid(cards, suits); % create 13×4 grid combining ranks and suits
deckCards = cardsGrid(:); % flatten ranks into 52×1 vector
deckSuits = suitsGrid(:); % flatten suits into 52×1 vector

% Shuffle the deck
order = randperm(length(deckCards)); % generate random order for all 52 cards
deckCards = deckCards(order); % shuffle rank order
deckSuits = deckSuits(order); % shuffle suits in same order

% Create cardValues array to store card values. Required so numbers 
% 11:13 from deckCards can still be indexed in cardNames.
cardValues = deckCards; % initialize card values from ranks
cardValues(cardValues > 10) = 10; % assign value 10 to J, Q, K
end

function [playerHands, cardIndex] = dealInitialHands(numPlayers, deckCards, deckSuits, cardValues) % function to deal two cards each
% Deals two cards to each player (including dealer)
% Player 1 is the dealer, the rest are human players

    % Initialize a cell array for each player's hand
    playerHands = cell(1, numPlayers); % create cell array for all hands
    cardIndex = 1; % track current deck position

    % Deal two cards to each player
    for p = numPlayers:-1:1 % deal from last player to dealer
        % Each player gets 2 cards from the deck
        playerHands{p}.cards = deckCards(cardIndex:cardIndex+1); % assign ranks
        playerHands{p}.suits = deckSuits(cardIndex:cardIndex+1); % assign suits
        playerHands{p}.values = cardValues(cardIndex:cardIndex+1); % assign point values
        
        % Move deck index forward
        cardIndex = cardIndex + 2; % skip past dealt cards
    end
end

function total = adjustForAces(values) % function to adjust Ace values if over 21
% Calculates total of hand treating Aces as 11 unless busting

    % Treat all Aces as 11 initially
    values(values == 1) = 11; % set Aces to high value (11)
    total = sum(values); % calculate total score

    % Downgrade Aces to 1 if bust
    numAces = sum(values == 11); % count how many Aces are currently high
    while total > 21 && numAces > 0 % while over 21 and can lower Aces
        total = total - 10; % convert one Ace from 11 to 1
        numAces = numAces - 1; % decrement number of high Aces
    end
end

function [playerHands, cardIndex] = playHand(playerHands, p, deckCards,deckSuits,... % function for a player’s turn
                                        cardValues, cardIndex, cardNames)
% Handles a single player's turn
% Input: playerHands cell array, player index, deck arrays, nextCardIndex, cardNames
% Output: updated playerHands and CardIndex

    hand = playerHands{p}; % copy current player's hand locally
    total = adjustForAces(hand.values); % calculate current total with Ace adjustment

    fprintf("\nPlayer %d's turn:\n", p); % print turn header

    while total < 21 % continue until player stands or busts
        fprintf("Current hand total: %d\n", total); % show running total

        % validation loop to make sure only hit or stay chosen
        validInput = false; % flag for valid choice
        while ~validInput % loop until valid input entered
            choice = input("Hit or stay? (h/s): ", 's'); % ask for player action
            choice = lower(choice); % normalize to lowercase

            if choice == 'h' || choice == 's' % check for valid letter
                validInput = true; % exit validation loop
            else
                fprintf("Invalid input. Please enter 'h' or 's'.\n"); % re-prompt on invalid input
            end
        end

        if choice == 'h' % player chooses to hit
            % Deal and add card to player's hand
            hand.cards(end+1) = deckCards(cardIndex); % draw next rank
            hand.suits(end+1) = deckCards(cardIndex); % (BUG) adds rank instead of suit, left unchanged intentionally
            hand.values(end+1) = deckCards(cardIndex); % (BUG) adds rank instead of value, left unchanged intentionally

            cardIndex = cardIndex + 1; % move to next card in deck

            % Show only card name and suit
            fprintf("You drew: %s of %s\n", cardNames(hand.cards(end)), hand.suits(end)); % print drawn card to console

            % Recalculate total using Ace logic
            total = adjustForAces(hand.values); % recompute total

            if total > 21 % check if player busted
                fprintf("Bust! Total = %d\n", total); % print bust message
                break; % exit turn if bust
            end
        else % player chooses to stay
            break; % exit loop and end turn
        end
    end

    % Save updated hand
    playerHands{p} = hand; % write updated hand back into cell array
end
