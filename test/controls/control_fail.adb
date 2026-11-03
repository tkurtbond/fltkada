--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Negative control: one failing check must make the test exit 1.

with Checks; use Checks;

procedure Control_Fail is
begin
    Check (True, "a check that passes");
    Check (False, "a check that fails on purpose");
    Summary;
end Control_Fail;
