import std.array;
import std.conv;
import std.file;

immutable lowerRBENV = "rbenv";
immutable upperRBENV = "RBENV";
immutable lowerDENV = "denv";
immutable upperDENV = "DENV";

string rbenvFileToDenvFile(string rbenvFile)
{
    return rbenvFile.replace(lowerRBENV, lowerDENV).replace(upperRBENV, upperDENV);
}

void rbToD(string rbenvFilename)
{
    immutable denvFilename = rbenvFilename.replace(lowerRBENV, lowerDENV);
    immutable denvFile = rbenvFileToDenvFile(read(rbenvFilename).to!string());
    write(denvFilename, denvFile);
}

void main()
{
    foreach (rbenvFilename; dirEntries("./libexec/", SpanMode.depth)) {
        rbToD(rbenvFilename);
        remove(rbenvFilename);
    }
}
