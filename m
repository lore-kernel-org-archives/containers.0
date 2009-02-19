From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/9] Multiple devpts instances
Date: Thu, 19 Feb 2009 14:46:37 -0800
Message-ID: <499DE14D.9050503@zytor.com>
References: <20081015053000.GA2039@us.ibm.com> <499D7E13.10601@free.fr>
	<499D97B1.1090902@zytor.com> <499DA069.3040603@free.fr>
	<499DB9DA.2070301@zytor.com> <499DE06E.4030108@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <499DE06E.4030108-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Daniel Lezcano wrote:
> 
> But if I am able to create a new instance of devpts for a container and 
> modify the configuration of another devpts from this container, is it 
> acceptable ? Can we convince people to use the containers for security 
> and have anybody able to make a pty starvation from one container to 
> another ?
> If it is too much complicated to handle one value per new devpts 
> instance, IMHO /proc/sys/kernel/pty/max should be, at least, read-only 
> for the new instance, no ?
> 

First of all, there is no such thing... the devpts instance is simply 
another filesystem, whereas the /proc/sys entry is a global limit on the 
total number of ptys in the system.  Again, one of thousands, and yes, 
they probably should ALL be readonly in a container environment.  That 
has to be set up separately than the devpts filesystem, because the 
devpts filesystem is not tied to procfs or even containers in any way.

	-hpa
