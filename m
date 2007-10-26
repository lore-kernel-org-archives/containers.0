From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: Q: How complete is the pid namespace in mainline
Date: Fri, 26 Oct 2007 10:17:18 -0700
Message-ID: <20071026171718.GB11942@us.ibm.com>
References: <m1bqam4fpg.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1bqam4fpg.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman [ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org] wrote:
| 
| Guys how complete do you fee the pid namespace support is that
| has been merged into Linus's tree?
| 
| My impression until I started reading through code earlier today
| was that the support was just about done except for a couple of
| tricky details.

The only thing that I know is pending is the issue of signalling
container-init. We have not been able to find a clean fix for it.

The problem now is that a process in a child namespace can terminate
its container-init and thereby the entire container. We have a 3-patch
set (Oleg's and mine) that kind of addresses this.  The scenario where
the patchset fails is :

	- the container-init has a blockable, fatal signal blocked 

	- a descendant of the container-init posts the fatal signal to
	  container-init.

	- container-init then unblocks the signal without ignoring or
	  handling the signal.

In this case again the container-init can be terminated. 

(by fatal I mean a signal whose default action is to terminate the process
SIGKILL is of couse not blockable and is not a problem)

This issue can be addressed in user-space by the container-init - which
should just ignore the fatal signal or setup a handler for it.

Dave had suggested we print a warning the first time a container-init forks()
without a handler for a fatal signal. I was planning on adding that as
patch 4 of the signal patch set and get some feedback.

Suka
