From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] pidns: Use task_active_pid_ns where appropriate
Date: Mon, 31 Jan 2011 16:36:53 +0100
Message-ID: <20110131153653.GA32392__31067.3008244068$1296488971$gmane$org@redhat.com>
References: <1296469525-30111-1-git-send-email-daniel.lezcano@free.fr>
	<1296469525-30111-5-git-send-email-daniel.lezcano@free.fr>
	<AANLkTikjcou-0b4NejpY66qXeZuzsC-M+oNTyHk=OE-Z@mail.gmail.com>
	<4D46CB9E.1090802@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D46CB9E.1090802-GANU6spQydw@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 01/31, Daniel Lezcano wrote:
>
> On 01/31/2011 12:26 PM, Alexey Dobriyan wrote:
>>
>> This task_active_pid_ns() is misnamed(?) because it does matter only
>> for dead tasks?
>
> Actually this function is later used, for the unshare, to get the pid_ns
> of a specific task, not the current one.

Well, it is already used to get the pid_ns of !current task.

> http://kerneltrap.org/mailarchive/linux-kernel/2010/6/20/4585095

The actual need for this change is that you are going to complicate
the things so that current->proxy->pid_ns != task_active_pid_ns().
This makes me cry ;)

Please don't forget, this patch is buggy, iirc...

Oleg.
