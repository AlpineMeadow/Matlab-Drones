function titleStr = getTitleStr(info, frameSeconds)

%This function will get the title string for the movie.  It is actually
%quite complicated due to the changing times.

yearStr = info.yearStr;
year = info.year;
monthStr = info.monthStr;
month = info.month;
dayOfMonthStr = info.dayOfMonthStr;
dayOfMonth = info.dayOfMonth;

hourStr = info.hourStr;
hour = info.hour;
minuteStr = info.hourStr;
minute = info.minute;
secondStr = info.secondStr;
second = info.second;


startMinute = minute;
minuteStr = num2str(startMinute, '%02d');

startSeconds = second;
totalSeconds = startSeconds + frameSeconds;
secondStr = num2str(totalSeconds, '%4.2f');

if totalSeconds >= 60.0
    %We need to change the minute value.
    startMinute = startMinute + 1;
    minuteStr = num2str(startMinute, '%02d');

    %We need to handle the second value.
    totalSeconds = totalSeconds - 60.0;
    left = fix(totalSeconds);
    leftStr = num2str(left, '%02d');
    right = totalSeconds - left;
    rightStr = num2str(fix(right*(1.0/info.movieFrameLength)), '%02d');
    secondStr = [leftStr, '.', rightStr];

    if startMinute >= 60.0
        %We need to change the hour value.
        startHour = hour + 1;
        hourStr = num2str(startHour, '%02d');
    end
    %We did not ever take data at around midnight so we will never change
    %the day or the month or the year!
end

titleStr = 'Events : ' + " " +  yearStr + " "  + ...
    monthStr + " " + dayOfMonthStr + " "  + ...
    hourStr + ":" + minuteStr + ":" + secondStr;

end  %End of the function getTitleStr.m