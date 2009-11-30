From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: how to handle devpts
Date: Mon, 30 Nov 2009 14:22:23 -0600
Message-ID: <20091130202223.GA20224@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

We currently checkpoint and restart unix98 ptys in the kernel.
So what do we want to do about the userspace part?  In particular,
if I run the following test program and checkpoint it, it
has `tty` open.  What do we want to do about that?

Just having user-cr/restart.c take an option to mount a new
instance of devpts isn't enough - we don't get hooked up to
restart.c's stdin/out obviously, and restart succeeds but the
restarted program exists with -EIO.  At the same time, just
doing a cradvise type of thing to plug fds 0,1,2 suffice for
this testcase, but not for something more complicated which
also has other unix98 ptys open.

Do we require that it be run in screen?  Then what about the
screen session's terminals themselves?

Anyway, I have this feeling that other have already thought
through this, so here is the simple program for discussion:

#include <stdio.h>
#include <curses.h>
#include <string.h>

int main(int argc, char *argv[])
{
#define MAXLEN 20
	char input[MAXLEN+1];
	int i = 0;

	initscr();
	cbreak();
	//noecho();
	nonl();
	intrflush(stdscr, FALSE);
	keypad(stdscr, TRUE);

	addstr("Enter some text: ");
	memset(input, 0, MAXLEN+1);
	while (1) {
		input[i] = getch();
		if (input[i] == KEY_ENTER || input[i]=='\r')
			break;
		i++;
		if (i == MAXLEN)
			break;
	}
	endwin();
	printf("I read the text: %s\n", input);
	return 0;
}

-serge
