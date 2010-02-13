From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 1/1] Syslog are now containerized
Date: Sat, 13 Feb 2010 11:13:21 -0800
Message-ID: <m1pr49ne3y.fsf@fess.ebiederm.org>
References: <201002110552.o1B5qwbL024561@kernel.safe.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <201002110552.o1B5qwbL024561-X4ZF2iejbABnc3BsFfMrZw@public.gmane.org> (Jean-Marc Pigeon's
	message of "Thu\, 11 Feb 2010 01\:00\:20 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jean-Marc Pigeon <jmp-4qkeo2rQ0gg@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Jean-Marc Pigeon <jmp-4qkeo2rQ0gg@public.gmane.org> writes:

> 	Added syslog.c such container /proc/kmsg and host /proc/kmsg
> 	do not leak in each other.
> 	Running rsyslog daemon within a container won't destroy
> 	host kernel messages.

If the goal is to not destroy the host kernel messages the much
simpler solution would be to simply disable /proc/kmsg in the container.
I expect we can get that for free with a some bug fixes to the user
namespace (aka if you are not in the global namespace you can't
touch /proc/kmsg).

Additionally except for the possible exception of logging firewall rules
I can't think of a case where I would want kernel printk's in anything
other than the global kernel ring buffer.

Eric
