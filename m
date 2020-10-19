Return-Path: <SRS0=bTwc=D2=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55000C433E7
	for <containers@archiver.kernel.org>; Mon, 19 Oct 2020 00:15:35 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B6DD722280
	for <containers@archiver.kernel.org>; Mon, 19 Oct 2020 00:15:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6DD722280
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 5159B86DE7;
	Mon, 19 Oct 2020 00:15:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id YVzb7LxmIrvA; Mon, 19 Oct 2020 00:15:33 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 4FB3686DE6;
	Mon, 19 Oct 2020 00:15:33 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 40790C088B;
	Mon, 19 Oct 2020 00:15:33 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 8F2B7C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 19 Oct 2020 00:15:32 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 76AFD86DE7
 for <containers@lists.linux-foundation.org>;
 Mon, 19 Oct 2020 00:15:32 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id TysMvADQk1Zs
 for <containers@lists.linux-foundation.org>;
 Mon, 19 Oct 2020 00:15:30 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from out03.mta.xmission.com (out03.mta.xmission.com [166.70.13.233])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 61A1D86DE6
 for <containers@lists.linux-foundation.org>;
 Mon, 19 Oct 2020 00:15:30 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
 by out03.mta.xmission.com with esmtps (TLS1.2) tls
 TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1kUIpX-006OrR-7X; Sun, 18 Oct 2020 18:15:15 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=x220.xmission.com) by in02.mta.xmission.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256) (Exim 4.87)
 (envelope-from <ebiederm@xmission.com>)
 id 1kUIpV-0005m0-CT; Sun, 18 Oct 2020 18:15:15 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Christian Brauner <christian.brauner@ubuntu.com>
References: <20200830143959.rhosiunyz5yqbr35@wittgenstein>
 <cb6c6f1a-89ee-1762-3eec-4f69bd7739b1@metux.net>
 <874kmsdcdx.fsf@x220.int.ebiederm.org>
 <20201018102026.34jtxfheygowgejp@wittgenstein>
 <87h7qradml.fsf_-_@x220.int.ebiederm.org>
Date: Sun, 18 Oct 2020 19:15:27 -0500
In-Reply-To: <87h7qradml.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
 message of "Sun, 18 Oct 2020 08:05:06 -0500")
Message-ID: <87o8kz840w.fsf@x220.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1kUIpV-0005m0-CT; ; ; mid=<87o8kz840w.fsf@x220.int.ebiederm.org>;
 ; ; hst=in02.mta.xmission.com; ; ; ip=68.227.160.95; ; ;
 frm=ebiederm@xmission.com; ; ; spf=neutral
X-XM-AID: U2FsdGVkX1/m3cQ7dhhCnCIVGG4AlnEhKaqD5SqxJz0=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: The problem of setgroups and containers
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
Cc: Alexander Mihalicyn <alexander@mihalicyn.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Joseph Christopher Sible <jcsible@cert.org>, Wat Lim <watl@google.com>,
 Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
 containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
 =?utf-8?Q?Micka=C3=ABl_Sala=C3=BCn?= <mic@digikod.net>,
 Andy Lutomirski <luto@amacapital.net>, Mrunal Patel <mpatel@redhat.com>,
 Pavel Tikhomirov <ptikhomirov@virtuozzo.com>,
 Geoffrey Thomas <geofft@ldpreload.com>
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

ebiederm@xmission.com (Eric W. Biederman) writes:

> [ Added linux-api because we are talking about a subtle semantic
>   change to the permission checks ]
>
> Christian Brauner <christian.brauner@ubuntu.com> writes:
>
>> On Sat, Oct 17, 2020 at 11:51:22AM -0500, Eric W. Biederman wrote:
>>> "Enrico Weigelt, metux IT consult" <lkml@metux.net> writes:
>>> 
>>> > On 30.08.20 16:39, Christian Brauner wrote:
>>> >> For mount points
>>> >>    that originate from outside the namespace, everything will show as
>>> >>    the overflow ids and access would be restricted to the most
>>> >>    restricted permission bit for any path that can be accessed.
>>> >
>>> > So, I can't just take a btrfs snapshot as rootfs anymore ?
>>> 
>>> Interesting until reading through your commentary I had missed the
>>> proposal to effectively effectively change the permissions to:
>>> ((mode >> 3) & (mode >> 6) & mode & 7).
>>> 
>>> The challenge is that in a permission triple it is possible to set
>>> lower permissions for the owner of the file, or for a specific group,
>>> than for everyone else.
>>> 
>>> Today we require root permissions to be able to map users and groups in
>>> /proc/<pid>/uid_map and /proc/<pid>/gid_map, and we require root
>>> permissions to be able to drop groups with setgroups.
>>> 
>>> Now we are discussiong moving to a world where we can use users and
>>> groups that don't map to any other user namespace in uid_map and
>>> gid_map.  It should be completely safe to use those users and groups
>>> except for negative permissions in filesystems.  So a big question is
>>> how do we arrange the system so anyone can use those files without
>>> negative permission causing problems.
>>> 
>>> 
>>> I believe it is safe to not limit the owner of a file, as the
>>> owner of a file can always chmode the file and remove any restrictions.
>>> Which is no worse than calling setuid to a different uid.
>>> 
>>> Which leaves where we have been dealing with the ability to drop groups
>>> with setgroups.
>>> 
>>> I guess the practical proposal is when the !in_group_p and we are
>>> looking at the other permission.  Treat the permissions as:
>>> ((mode >> 3) & mode & 7).  Instead of just (mode & 7).
>>> 
>>> Which for systems who don't use negative group permissions is a no-op.
>>> So this should not effect your btrfs snapshots at all (unless you use
>>> negative group permissions).
>>> 
>>> It denies things before we get to an NFS server or other interesting
>>> case so it should work for pretty much everything the kernel deals with.
>>> 
>>> Userspace repeating permission checks could break.  But that is just a
>>> problem of inconsistency, and will always be a problem.
>>> 
>>> We could make it more precise as Serge was suggesting with a set of that
>>> were dropped from setgroups, but under the assumption that negative
>>> groups are sufficient rare we can avoid that overhead.
>>
>> I'm tempted to agree and say that it's safe to assume that they are used
>> very much. Negative acls have been brought up a couple of times in
>> related contexts though. One being a potential bug in newgidmap which we
>> discussed back in
>> https://bugs.launchpad.net/ubuntu/+source/shadow/+bug/1729357
>> But I think if we have this under a sysctl as proposed earlier is good
>> enough.
>>
>>> 
>>>  static int acl_permission_check(struct inode *inode, int mask)
>>>  {
>>>  	unsigned int mode = inode->i_mode;
>>>  
>>> - [irrelevant bits of this function]        
>>>  
>>>  	/* Only RWX matters for group/other mode bits */
>>>  	mask &= 7;
>>>  
>>>  	/*
>>>  	 * Are the group permissions different from
>>>  	 * the other permissions in the bits we care
>>>  	 * about? Need to check group ownership if so.
>>>  	 */
>>>  	if (mask & (mode ^ (mode >> 3))) {
>>>  		if (in_group_p(inode->i_gid))
>>>  			mode >>= 3;
>>> +		/* Use the most restrictive permissions? */
>>> +		else (current->user_ns->flags & USERNS_ALWAYS_DENY_GROUPS)
>>> +			mode &= (mode >> 3);
>>>  	}
>>>  
>>>  	/* Bits in 'mode' clear that we require? */
>>>  	return (mask & ~mode) ? -EACCES : 0;
>>>  }
>>> 
>>> As I read posix_acl_permission all of the posix acls for groups are
>>> positive permissions.  So I think the only other code that would need to
>>> be updated would be the filesystems that replace generic_permission with
>>> something that doesn't call acl_permission check.
>>> 
>>> Userspace could then activate this mode with:
>>> 	echo "safely_allow" > /proc/<pid>/setgroups
>>> 
>>> That looks very elegant and simple, and I don't think will cause
>>> problems for anyone.  It might even make sense to make that the default
>>> mode when creating a new user namespace.
>>> 
>>> I guess we owe this idea to Josh Triplett and Geoffrey Thomas.
>>> 
>>> Does anyone see any problems with tweaking the permissions this way so
>>> that we can always allow setgroups in a user namespace?
>>
>> This looks sane and simple. I would still think that making it opt-in
>> for a few kernel releases might be preferable to just making it the new
>> default. We can then revisit flipping the default. Advanced enough
>> container runtimes will quickly pick up on this and can make it the
>> default for their unprivileged containers if they want to.
>
> I think we can even do a little bit better than what I proposed above.
> The downside of my code is that negtative acls won't work in containers
> even if they do today.  (Not that I think negative acls are something to
> encourage just that breaking them means we have to deal with the
> question: "Does someone care?").
>
> What we can very safely do is limit negative acls to filesystems that
> are mounted in the same user namespace.  Like the code below.
>
>  static int acl_permission_check(struct inode *inode, int mask)
>  {
>  	unsigned int mode = inode->i_mode;
>  
> - [irrelevant bits of this function]        
>  
>  	/* Only RWX matters for group/other mode bits */
>  	mask &= 7;
>  
>  	/*
>  	 * Are the group permissions different from
>  	 * the other permissions in the bits we care
>  	 * about? Need to check group ownership if so.
>  	 */
>  	if (mask & (mode ^ (mode >> 3))) {
>  		if (in_group_p(inode->i_gid))
>  			mode >>= 3;
> +		/*
> +		 * In a user namespace groups may have been dropped
> +		 * so use the most restrictive permissions.
> +		 */
> +		else if (current->user_ns != inode->i_sb->user_ns)
> +			mode &= (mode >> 3);
>  	}
>  
>  	/* Bits in 'mode' clear that we require? */
>  	return (mask & ~mode) ? -EACCES : 0;
>  }
>
> I would make the plan that we apply the fully fleshed out version of the
> above (aka updating the permission methods that don't use
> generic_permission), and then in a following kernel cycle we remove the
> restrictions on setgroups because they are no longer needed.
>
> The only possible user breaking issue I can see if a system with
> negative acls where the containers rely on having access to the other
> permissions for some reason.  If someone finds a system that does this
> change would need to be reverted and another plan would need to be
> found.  Otherwise I think/hope this is a safe semantic change.
>
> Does anyone see any problems with my further simplification?

Ugh.  I do see a problem.  Not with the approach so much but with my
argument that it is fine to ignore users.

I have just re-read through posix_acl_permission, and the logic is just
like acl_permission_check except that instead of having one user (the
owner of the file) and one group.  There can be the owner of the file
and other users (each with their distinct permissions) followed by the
one or more groups each with their distinct permissions followed by a
mask of maximum permissions followed by permissions for other users.

Which means that we need to take the owner of the user namespace into
account to preserve the invariant that we have no more permissions than
that owner had.

So I am thinking for the other permission check we need to limit the
permissions that are available to based on recursively the owner of the
user namespace and the owner's groups when the user namespace was
created.


Eric
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
