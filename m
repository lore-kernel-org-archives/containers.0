From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] userns: Allow the unprivileged users to mount mqueue
 fs
Date: Mon, 28 Jan 2013 14:48:15 +0800
Message-ID: <51061F2F.6040104@cn.fujitsu.com>
References: <1359342541-383-1-git-send-email-gaofeng@cn.fujitsu.com>
	<87bocayntu.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87bocayntu.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2013/01/28 11:43, Eric W. Biederman wrote:
> Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
> 
>> This patch allow the unprivileged user to mount mqueuefs in
>> user ns.
>>
>> If two userns share the same ipcns,the files in mqueue fs
>> should be seen in both these two userns.
>>
>> If the userns has its own ipcns,it has its own mqueue fs too.
>> ipcns has already done this job well.
> 
> I am a little dense.  When does userspace actually mount a mqueuefs?
> My impression was that user space never needed to mount and actually
> never could mount a mqueuefs.  MS_NO_USER isn't set so mounting a
> mqueuefs is possible but when does it happen and why?
> 

Actually the files which representative messgae queue in mqueuefs contains
some informations,such as QSIZE,NOTIFY,SIGNO,NOTIFY_PID.

My workstation is Fedora 17,mqueuefs is mounted on /dev/mqueue by default.
So I think at lest this patch is needed by some people.

Thanks!
Gao

> I am trying to think through the logic here and I think this is safe
> but since I don't understand why we would mount an mqueue fs I am
> having trouble verifying that there are no silly reasons why this might
> be a bad idea.
> 
> But from what I can tell so far this seems like a good patch.
> 
> Eric
> 
> 
>> Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>> ---
>>  ipc/mqueue.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/ipc/mqueue.c b/ipc/mqueue.c
>> index 71a3ca1..023c986 100644
>> --- a/ipc/mqueue.c
>> +++ b/ipc/mqueue.c
>> @@ -1383,6 +1383,7 @@ static struct file_system_type mqueue_fs_type = {
>>  	.name = "mqueue",
>>  	.mount = mqueue_mount,
>>  	.kill_sb = kill_litter_super,
>> +	.fs_flags = FS_USERNS_MOUNT,
>>  };
>>  
>>  int mq_init_ns(struct ipc_namespace *ns)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
