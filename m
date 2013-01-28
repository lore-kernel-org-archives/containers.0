From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] userns: Allow the unprivileged users to mount mqueue fs
Date: Sun, 27 Jan 2013 23:14:48 -0800
Message-ID: <877gmxye1j.fsf@xmission.com>
References: <1359342541-383-1-git-send-email-gaofeng@cn.fujitsu.com>
	<87bocayntu.fsf@xmission.com> <51061F2F.6040104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51061F2F.6040104-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> (Gao feng's message of "Mon, 28
	Jan 2013 14:48:15 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:

> On 2013/01/28 11:43, Eric W. Biederman wrote:
>> Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
>> 
>>> This patch allow the unprivileged user to mount mqueuefs in
>>> user ns.
>>>
>>> If two userns share the same ipcns,the files in mqueue fs
>>> should be seen in both these two userns.
>>>
>>> If the userns has its own ipcns,it has its own mqueue fs too.
>>> ipcns has already done this job well.
>> 
>> I am a little dense.  When does userspace actually mount a mqueuefs?
>> My impression was that user space never needed to mount and actually
>> never could mount a mqueuefs.  MS_NO_USER isn't set so mounting a
>> mqueuefs is possible but when does it happen and why?
>> 
>
> Actually the files which representative messgae queue in mqueuefs contains
> some informations,such as QSIZE,NOTIFY,SIGNO,NOTIFY_PID.
>
> My workstation is Fedora 17,mqueuefs is mounted on /dev/mqueue by default.
> So I think at lest this patch is needed by some people.

I have just confirmed that the most you can do in a mounted mqueue fs is
to create files message queues.

Given that these filesystems exist anyway I don't see a problem.

Applied thanks.

Eric
