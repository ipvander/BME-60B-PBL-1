% Ian Van Der Linde, Ryan Shabbak, Trevor Holmgren
% 10/21/25
% This script creates a blackjack game
clear all; close all; clc;
% Create card names for dialogue
cardNames = ["Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10",...
    "Jack", "Queen", "King"];

% Create the deck of cards
[deckCards, deckSuits, cardValues] = createDeck();
% Ask how many are playing
numPlayers = 1 + menu('Select number of players: ', 'One', 'Two', 'Three', 'Four');

switch (numPlayers - 1)
    case 1
      fprintf('You selected One player \n');
    case 2
      fprintf('You selected Two players');
    case 3
      fprintf('You selected Three players');
    case 4
       fprintf('You selected Four players')
    otherwise
      disp('Error D:');
end
pause(1.5);
% Create player and dealer hands
[playerHands, cardIndex] = dealInitialHands(numPlayers, deckCards, deckSuits, cardValues);

% Show initial hands MAKE SURE TO HIDE DEALER FIRST CARD
for p = numPlayers:-1:1
    if p == 1
        fprintf("\nDealer's Hand:\n");
        for c = 1
            fprintf("%d. Hidden\n", c)
        end
        for c = 2
        fprintf("%d. %s of %s \n", c, cardNames(playerHands{p}.cards(c)), ...
            playerHands{p}.suits(c));
        end
    else
        fprintf("\nPlayer %d's Hand:\n", p - 1);
        for c = 1:2
        fprintf("%d. %s of %s \n", c, cardNames(playerHands{p}.cards(c)), ...
            playerHands{p}.suits(c));
        end
    end
end
pause(3);
% Going through every players' turns except dealer
for p = numPlayers(end):-1:2
    [playerHands, cardIndex] = playHand(playerHands, p, deckCards,deckSuits,...
                                        cardValues, cardIndex, cardNames);
end

% Dealer plays last
fprintf("\n--- Dealer's Turn ---\n");
dealerTotal = adjustForAces(playerHands{1}.values);
fprintf("Dealer's hand:\n");
for c = 1:length(playerHands{1}.cards)
    fprintf("  %s of %s\n", cardNames(playerHands{1}.cards(c)), playerHands{1}.suits(c));
end
fprintf("Dealer's total: %d\n", dealerTotal);

% Dealer hits until total >= 17
while dealerTotal < 17
    fprintf("Dealer hits.\n");
    pause(1.5);
    playerHands{1}.cards(end+1) = deckCards(cardIndex);
    playerHands{1}.suits(end+1) = deckSuits(cardIndex);
    playerHands{1}.values(end+1) = cardValues(cardIndex);
    cardIndex = cardIndex + 1;
    
    dealerTotal = adjustForAces(playerHands{1}.values);
    fprintf("Dealer drew %s of %s (total = %d)\n", ...
        cardNames(playerHands{1}.cards(end)), playerHands{1}.suits(end), dealerTotal);
end

if dealerTotal > 21
    fprintf("Dealer busts!\n");
    pause(1.5);
end

% Determine results
fprintf("\n--- Results ---\n");
for p = 2:numPlayers
    playerTotal = adjustForAces(playerHands{p}.values);
    fprintf("\nPlayer %d total: %d\n", p-1, playerTotal);
    fprintf("Dealer total: %d\n", dealerTotal);
    pause(1.5);
    if playerTotal > 21
        fprintf("Player %d busts! Dealer wins.\n", p-1);
    elseif dealerTotal > 21
        fprintf("Dealer busts! Player %d wins!\n", p-1);
    elseif playerTotal > dealerTotal
        fprintf("Player %d wins!\n", p-1);
    elseif playerTotal < dealerTotal
        fprintf("Dealer wins against Player %d.\n", p-1);
    else
        fprintf("Push! Player %d ties with the Dealer.\n", p-1);
    end
end
pause(1.5);
fprintf("\nGame over!\n");










function [deckCards, deckSuits, cardValues] = createDeck()
% This function creates a shuffled deck of cards 
% Create cards and suits
cards = 1:13;
suits = ["Spades","Hearts", "Diamonds", "Clubs"];

% Create a grid of 52 cards, numbers 1:13, with assigned suits 1:4
[cardsGrid, suitsGrid] = ndgrid(cards, suits);
deckCards = cardsGrid(:); %Creates column of card # repeated 4 times
deckSuits = suitsGrid(:); %Creates column of suits repeated 13 times each

% Shuffle the deck
order = randperm(length(deckCards));
deckCards = deckCards(order);
deckSuits = deckSuits(order);

% Create cardValues array to store card values. Required so numbers 
% 11:13 from deckCards can still be indexed in cardNames.
cardValues = deckCards;
cardValues(cardValues > 10) = 10;
end


function [playerHands, cardIndex] = dealInitialHands(numPlayers, deckCards, deckSuits, cardValues)
% Deals two cards to each player (including dealer)
% Player 1 is the dealer, the rest are human players

    % Initialize a cell array for each player's hand
    playerHands = cell(1, numPlayers);
    cardIndex = 1; % Keeps track of where we are in the deck

    % Deal two cards to each player
    for p = numPlayers:-1:1  % Count down so dealer (player 1) gets last hand
        % Each player gets 2 cards from the deck
        playerHands{p}.cards = deckCards(cardIndex:cardIndex+1);
        playerHands{p}.suits = deckSuits(cardIndex:cardIndex+1);
        playerHands{p}.values = cardValues(cardIndex:cardIndex+1);
        
        % Move deck index forward
        cardIndex = cardIndex + 2;
    end
end

function total = adjustForAces(values)
% Calculates total of hand treating Aces as 11 unless busting

    % Treat all Aces as 11 initially
    values(values == 1) = 11;
    total = sum(values);

    % Downgrade Aces to 1 if bust
    numAces = sum(values == 11);
    while total > 21 && numAces > 0
        total = total - 10;
        numAces = numAces - 1;
    end
end

function [playerHands, cardIndex] = playHand(playerHands, p, deckCards,deckSuits,...
                                        cardValues, cardIndex, cardNames)
% Handles a single player's turn
% Input: playerHands cell array, player index, deck arrays, nextCardIndex, cardNames
% Output: updated playerHands and CardIndex

    hand = playerHands{p};
    total = adjustForAces(hand.values);

    fprintf("\nPlayer %d's turn:\n", p - 1);

    while total < 21
        fprintf("Current hand total: %d\n", total);
        %While loop for hitting or staying
        playerHit = menu('Hit or stay?', 'Hit', 'Stay');
            switch (playerHit)
                case 1
                    fprintf('You Hit \n');
                    % Deal and add card to player's hand
                    hand.cards(end+1) = deckCards(cardIndex); 
                    hand.suits(end+1) = deckSuits(cardIndex);
                    hand.values(end+1) = cardValues(cardIndex);

                    cardIndex = cardIndex + 1;

                    % Show only card name and suit
                    fprintf("You drew: %s of %s\n", cardNames(hand.cards(end)), hand.suits(end));

                    % Recalculate total using Ace logic
                    total = adjustForAces(hand.values);

                    if total > 21
                        fprintf("Bust! Total = %d\n", total); % Busts then total score
                        pause(1.5);
                        break;
                     end
                case 2
                    fprintf('You Stayed \n');
                    break;
                otherwise
                    disp('Error D:');
            end
    end

    % Save updated hand
    playerHands{p} = hand;
end
