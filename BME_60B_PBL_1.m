% Ian Van Der Linde, Ryan Shabbak, Trevor Holmgren
% 10/21/25
% This script creates a blackjack game

clear all; close all; clc

% Create card names for dialogue
cardNames = ["Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10",...
    "Jack", "Queen", "King"];

% Create the deck of cards
[deckCards, deckSuits, cardValues] = createDeck();

% Ask how many are playing
numPlayers = input("Enter number of players (including dealer): ");

% Create player and dealer hands
[playerHands, CardIndex] = dealInitialHands(numPlayers, deckCards, deckSuits, cardValues)












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


function [playerHands, CardIndex] = dealInitialHands(numPlayers, deckCards, deckSuits, cardValues)
% Deals two cards to each player (including dealer)
% Player 1 is the dealer, the rest are human players

    % Initialize a cell array for each player's hand
    playerHands = cell(1, numPlayers);
    CardIndex = 1; % Keeps track of where we are in the deck

    % Deal two cards to each player
    for p = numPlayers:-1:1  % Count down so dealer (player 1) gets last hand
        % Each player gets 2 cards from the deck
        playerHands{p}.cards = deckCards(CardIndex:CardIndex+1);
        playerHands{p}.suits = deckSuits(CardIndex:CardIndex+1);
        playerHands{p}.values = cardValues(CardIndex:CardIndex+1);
        
        % Move deck index forward
        CardIndex = CardIndex + 2;
    end
end


