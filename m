From: Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] Send a SIGCHLD to the init's pid namespace parent
	when reboot
Date: Tue, 23 Aug 2011 16:09:26 +0200
Message-ID: <1314108566.3465.29.camel__2153.91122405908$1314108637$gmane$org@bahia.local>
References: <20110814161707.GB30846@redhat.com>
	<20110814213642.GB13799@hallyn.com>	<20110815144744.GA9660@redhat.com>
	<4E4DA461.8030006@free.fr>	<20110819152416.GA17034@redhat.com>
	<4E524B73.3050704@free.fr>	<20110822154448.GA8527@redhat.com>
	<20110822183134.10390b46@neptune.home>	<20110822173949.GA13242@redhat.com>
	<20110822211716.7c141d5c@neptune.home>
	<20110823133302.GA19582@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110823133302.GA19582-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Bruno =?ISO-8859-1?Q?Pr=E9mont?= <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2011-08-23 at 15:33 +0200, Oleg Nesterov wrote:
> [...]
> At least now I understand why did you mention si_code/CLD before. You
> meant waitid(). I thought you were talking about the death-notifications
> which can't report CLD_ you need.
> 
> I strongly object. We shouldn't uglify wait_task_zombie() to solve the
> very specific problem.
> 
> And once again. sub_init->parent does wiat(&status) and sees
> WIFSIGNALED() && WTERMSIG(status) == SIGHUP. This can only mean that
> sys_reboot(LINUX_REBOOT_CMD_RESTART) was called. It _can not_ be really
> killed by SIGHUP, it must be CMD_RESTART.
> 
> Why this can't work? Why do you want the additional complications?
> 

I don't see either what could go wrong with you approach. It doesn't
mess with critical wait() or signal paths. It's definitely the way to
go.

Thanks.

-- 
Gregory Kurz                                     gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Software Engineer @ IBM/Meiosys                  http://www.ibm.com
Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.
