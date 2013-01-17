From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH RESEND] userns: enable tmpfs support for user namespace
Date: Thu, 17 Jan 2013 02:15:22 -0800
Message-ID: <87fw20f745.fsf@xmission.com>
References: <1358331945-4106-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20130116143532.GA4035@sergelap> <50F74EC6.60004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <50F74EC6.60004-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> (Gao feng's message of "Thu, 17
	Jan 2013 09:07:18 +0800")
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:

> On 2013/01/16 22:35, Serge Hallyn wrote:
>> Quoting Gao feng (gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
>>> From: gaofeng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>>>
>>> Since the memory used by tmpfs is under control of
>>> memory cgroup. and the files under the tmpfs will not
>>> be leak to other tmpfs.
>>>
>>> So mounting tmpfs in user namespace does no harm to the
>>> host,we can allow tmpfs to be mounted in user namespace.
>>>
>>> Signed-off-by: gaofeng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>> 
>> I've got the same patch in my kernel at
>> http://kernel.ubuntu.com/git?p=serge/quantal-userns.git;a=summary
>> 
>> except note that there are two definitions of shmem_fs_type.
>> 
>
> Yes, I miss the other one,Do you have plan to push this patch
> into linus's linux-2.6 or eric's userns tree?

Linus's linux-2.6.git is a symlink to Linus's linux.git  Talking about
2.6 in this day and age is a bit confusing.

> I'm trying to add userns support for libvirt,so I need tmpfs to
> be allowed to mount in userns.

At a practical level I am happy to apply a complete patch in my tree
once if it gets posted to fs-devel and probably lkml for review,
and I have had a chance to read the memory control group and verify
with my own little eyes that the memory control group can in fact limit
tmpfs.

Eric
