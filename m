From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH-user-cr] restart: handle dead/dummy tasks like ghosts
Date: Thu, 01 Oct 2009 10:59:34 -0400
Message-ID: <4AC4C3D6.3060509@librato.com>
References: <1254360988-29553-1-git-send-email-orenl@librato.com>
	<20091001032650.GA9491@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091001032650.GA9491-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
>> In "subtree" restart (restarting not inside a container), 'restart'
>> uses prctl(PR_DEATH_SIGNAL,...) to ensure proper cleanup should the
>> restart fail prematurely. The death_signal is sent, recursively, to
>> all the descendants of root to force-kill them.
>>
>> However, dead (dummy) tasks, marked with TASK_DEAD, used to exit
>> during the creation of the task tree. Since the task is not within
>> sys_restart it does not have the PF_RESTARTING, and therefore will
>> send the death_signal its children as it exits.
>>
>> To fix it, we observe that dead tasks are much like ghost tasks:
>> they are expected to terminate from within sys_restart, and before
>> the other tasks may resume execution. So we now treat dead (dummy)
>> tasks similarly to ghost tasks.
>>
>> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> 
> Hmm?  But at line 1540 you are still doing do_exit if it's
> TASK_DEAD  :)

Oops... I thought I removed it... will do.

Oren.
