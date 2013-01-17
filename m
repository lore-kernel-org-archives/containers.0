From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH RESEND] userns: enable tmpfs support for user namespace
Date: Thu, 17 Jan 2013 09:07:18 +0800
Message-ID: <50F74EC6.60004@cn.fujitsu.com>
References: <1358331945-4106-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20130116143532.GA4035@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130116143532.GA4035@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On 2013/01/16 22:35, Serge Hallyn wrote:
> Quoting Gao feng (gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
>> From: gaofeng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>>
>> Since the memory used by tmpfs is under control of
>> memory cgroup. and the files under the tmpfs will not
>> be leak to other tmpfs.
>>
>> So mounting tmpfs in user namespace does no harm to the
>> host,we can allow tmpfs to be mounted in user namespace.
>>
>> Signed-off-by: gaofeng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> 
> I've got the same patch in my kernel at
> http://kernel.ubuntu.com/git?p=serge/quantal-userns.git;a=summary
> 
> except note that there are two definitions of shmem_fs_type.
> 

Yes, I miss the other one,Do you have plan to push this patch
into linus's linux-2.6 or eric's userns tree?

I'm trying to add userns support for libvirt,so I need tmpfs to
be allowed to mount in userns.

Thanks!

>> ---
>>  mm/shmem.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index 5dd56f6..8eff60a 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -2766,6 +2766,7 @@ static struct file_system_type shmem_fs_type = {
>>  	.name		= "tmpfs",
>>  	.mount		= shmem_mount,
>>  	.kill_sb	= kill_litter_super,
>> +	.fs_flags	= FS_USERNS_MOUNT,
>>  };
>>  
>>  int __init shmem_init(void)
>> -- 
>> 1.7.11.7
>>
> 
