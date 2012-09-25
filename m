From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 17/25] userns: Convert minix to use kuid/kgid where
	appropriate
Date: Tue, 25 Sep 2012 03:51:28 -0700
Message-ID: <87bogupe8f.fsf@xmission.com>
References: <877grox6ql.fsf@xmission.com>
	<1348141326-23355-1-git-send-email-ebiederm@xmission.com>
	<1348141326-23355-17-git-send-email-ebiederm@xmission.com>
	<506176B5.9020104@gmail.com> <87obkupgcr.fsf@xmission.com>
	<50618A93.1040202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <50618A93.1040202-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Zhao Hongjiang's message of "Tue,
	25 Sep 2012 18:42:27 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Zhao Hongjiang <zhaohongjiang37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Zhao Hongjiang <zhaohongjiang37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

>>>
>>> 	i_uid_write(inode, (uid_t)raw_inode->i_uid);
>>> 	i_gid_write(inode, (gid_t)raw_inode->i_gid);
>>>
>>> is more better?
>> 
>> An extra cast to uid_t or gid_t is redundant.  i_uid_write takes
>> a uid_t paramenter and i_gid_write takes a gid_t paramenter so
>> we already have the casts implicitly.
>> 
>> Eric
>
> I see,this is mean that we should remove uid_t and gid_t casts in other patches which
> is in i_uid_write and i_gid_write?

Do you know of any such cases.

I certainly don't remember extraneous casts be a usual pattern in the kernel.

Eric
