//
//  Constants.swift
//  Tracker
//
//  Created by Aleksei Frolov on 16.11.2024.
//

import Foundation

enum Constants {
    static let tabBarItemTrackers = "Трекеры"
    static let tabBarItemStatistic = "Статистика"
    
    static let trackersVcTitleLabel = "Трекеры"
    static let trackersVcSearchPlaceholder = "Поиск"
    static let trackersVcPlaceholderLabel = "Что будем отслеживать?"
    static let trackersVcTrackerCellId = "TrakerCell"
    static let trackersVcTrackerCategoryHeaderId = "TrackerCategoryHeader"
    
    static let trackerTypeSelectionVcTitle = "Создание трекера"
    static let trackerTypeSelectionVcHabit = "Привычка"
    static let trackerTypeSelectionVcIrregularEvent = "Нерегулярное событие"
    static let trackerCellPlusButtonSystemName = "plus"
    
    static let scheduleVcTitle = "Расписание"
    static let scheduleVcReadyButtonTitle = "Готово"
    static let scheduleVcCellId = "ScheduleCell"
    
    static let eventVcCategoryTitle = "Категория"
    static let eventVcNewHabitCreationTitle = "Новая привычка"
    static let eventVcNewIrregularEventCreationTitle = "Новое нерегулярное событие"
    static let eventVcTextFieldPlaceholderTitle = "Введите название трекера"
    static let eventVcEmojiLabelTitile = "Emoji"
    static let eventVcColorLabelTitle = "Цвет"
    static let eventVcCancelButtonTitle = "Отменить"
    static let eventVcCreateButtonTitle = "Создать"
    static let eventVcTableViewCellId = "tableCell"
    static let eventVcEmojiCollectionCellId = "emojiCell"
    static let eventVcColorCollectionCellId = "colorCell"
    static let eventVcMaxNameLength = 38
    static let eventVcMaxNameLengthErrorText = "Ограничение 38 символов"
    static let eventVcClearButtonSystemName = "xmark.circle.fill"
    
    static let categoryVcPlaceholderLabel = "Привычки и события можно \n объединить по смыслу"
    static let categoryVcAddButtonTitle = "Добавить категорию"
    static let newCategoryVcTitle = "Новая категория"
    static let newCategoryVcPlaceholder = "Введите название категории"
    
    static let coreDataStackModelName = "TrackerModel"
    
    // Перечисление дополняется
    
}
