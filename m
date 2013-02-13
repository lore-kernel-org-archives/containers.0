From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH RFC 09/12] userns: Convert ocfs2 to use kuid and kgid
	where appropriate
Date: Wed, 13 Feb 2013 09:12:37 -0800
Message-ID: <874nhg5e9m.fsf@xmission.com>
References: <87pq38wimv.fsf@xmission.com>
	<1353415420-5457-1-git-send-email-ebiederm@xmission.com>
	<1353415420-5457-9-git-send-email-ebiederm@xmission.com>
	<20121121195114.GM2822@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121121195114.GM2822@localhost> (Joel Becker's message of "Wed,
	21 Nov 2012 11:51:15 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org> writes:

> On Tue, Nov 20, 2012 at 04:43:37AM -0800, Eric W. Biederman wrote:
>> --- a/fs/ocfs2/file.c
>> +++ b/fs/ocfs2/file.c
>> @@ -1116,7 +1116,8 @@ int ocfs2_setattr(struct dentry *dentry, struct iattr *attr)
>>  			    (unsigned long long)OCFS2_I(inode)->ip_blkno,
>>  			    dentry->d_name.len, dentry->d_name.name,
>>  			    attr->ia_valid, attr->ia_mode,
>> -			    attr->ia_uid, attr->ia_gid);
>> +			    from_kuid(&init_user_ns, attr->ia_uid),
>> +			    from_kgid(&init_user_ns, attr->ia_gid));
>
> Dear Eric,
> 	I have a similar question about init_user_ns to Dave.  As far as
> I can tell, using init_user_ns here means we'll never get translations
> based on the current process namespace.  It just so happens that
> include/linux/user_namespace.h doesn't allow new namespaces yet, but I
> can't see why we would propagate that knowledge elsewhere.
>
> 	Is there some magic about when init_user_ns should be used
> regardless?

Trace statements are fancy print statements, and the tracing
infrastructure is not setup to deal with anyone other than the
one-true-root using it.  Trace is like printk in that way.

So for print statements I always convert the value into the initial user
namespace which every value can be converted to without loss, and is the
same value that we have always been printing.

If at some point the tracing people figure out how deal with multiple
user namespaces it won't be hard to pass the kuids and kgids into the
trace funtions and have the readers of the data perform the conversions.

Eric
