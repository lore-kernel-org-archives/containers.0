Return-Path: <SRS0=5CWv=DV=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C533EC433E7
	for <containers@archiver.kernel.org>; Wed, 14 Oct 2020 19:46:41 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 37E6A21D7F
	for <containers@archiver.kernel.org>; Wed, 14 Oct 2020 19:46:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37E6A21D7F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id A43B8881C7;
	Wed, 14 Oct 2020 19:46:40 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id WWyIkYUi+1ed; Wed, 14 Oct 2020 19:46:39 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id B2EF388172;
	Wed, 14 Oct 2020 19:46:39 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 559F2C07FF;
	Wed, 14 Oct 2020 19:46:39 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 93D59C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 14 Oct 2020 19:46:37 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 8242087940
 for <containers@lists.linux-foundation.org>;
 Wed, 14 Oct 2020 19:46:37 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id d4Xwe38hQeGH
 for <containers@lists.linux-foundation.org>;
 Wed, 14 Oct 2020 19:46:36 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from out02.mta.xmission.com (out02.mta.xmission.com [166.70.13.232])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 9E8AD8778E
 for <containers@lists.linux-foundation.org>;
 Wed, 14 Oct 2020 19:46:36 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
 by out02.mta.xmission.com with esmtps (TLS1.2) tls
 TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1kSmjE-00CGrH-J5; Wed, 14 Oct 2020 13:46:28 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=x220.xmission.com) by in02.mta.xmission.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256) (Exim 4.87)
 (envelope-from <ebiederm@xmission.com>)
 id 1kSmjD-0008OD-AJ; Wed, 14 Oct 2020 13:46:28 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: "Serge E. Hallyn" <serge@hallyn.com>
References: <20200830143959.rhosiunyz5yqbr35@wittgenstein>
 <20201010042606.GA30062@mail.hallyn.com>
 <20201011205306.GC17441@localhost>
 <CALCETrUZcHNwspz315KFvSPxtK8MmLUPfiN=hCBgx+wqeJe4+g@mail.gmail.com>
 <87h7r0qbqi.fsf@x220.int.ebiederm.org>
 <20201012150006.GA3503@mail.hallyn.com>
Date: Wed, 14 Oct 2020 14:46:46 -0500
In-Reply-To: <20201012150006.GA3503@mail.hallyn.com> (Serge E. Hallyn's
 message of "Mon, 12 Oct 2020 10:00:06 -0500")
Message-ID: <87wnzsmvyx.fsf@x220.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1kSmjD-0008OD-AJ; ; ; mid=<87wnzsmvyx.fsf@x220.int.ebiederm.org>;
 ; ; hst=in02.mta.xmission.com; ; ; ip=68.227.160.95; ; ;
 frm=ebiederm@xmission.com; ; ; spf=neutral
X-XM-AID: U2FsdGVkX1/dzA0ojHgVFG1accwEPvk6reMlSI0NUgI=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: LPC 2020 Hackroom Session: summary and next steps for isolated
 user namespaces
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
Cc: Alexander Mihalicyn <alexander@mihalicyn.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Joseph Christopher Sible <jcsible@cert.org>, Kees Cook <keescook@chromium.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Josh Triplett <josh@joshtriplett.org>, Vivek Goyal <vgoyal@redhat.com>,
 Andy Lutomirski <luto@kernel.org>,
 =?utf-8?Q?Micka=C3=ABl_Sal?= =?utf-8?Q?a=C3=BCn?= <mic@digikod.net>,
 Wat Lim <watl@google.com>, Mrunal Patel <mpatel@redhat.com>,
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

"Serge E. Hallyn" <serge@hallyn.com> writes:

> On Mon, Oct 12, 2020 at 12:01:09AM -0500, Eric W. Biederman wrote:
>> Andy Lutomirski <luto@kernel.org> writes:
>> 
>> > On Sun, Oct 11, 2020 at 1:53 PM Josh Triplett <josh@joshtriplett.org> wrote:
>> >>
>> >> On Fri, Oct 09, 2020 at 11:26:06PM -0500, Serge E. Hallyn wrote:
>> >> > > 3. Find a way to allow setgroups() in a user namespace while keeping
>> >> > >    in mind the case of groups used for negative access control.
>> >> > >    This was suggested by Josh Triplett and Geoffrey Thomas. Their idea was to
>> >> > >    investigate adding a prctl() to allow setgroups() to be called in a user
>> >> > >    namespace at the cost of restricting paths to the most restrictive
>> >> > >    permission. So if something is 0707 it needs to be treated as if it's 0000
>> >> > >    even though the caller is not in its owning group which is used for negative
>> >> > >    access control (how these new semantics will interact with ACLs will also
>> >> > >    need to be looked into).
>> >> >
>> >> > I should probably think this through more, but for this problem, would it
>> >> > not suffice to add a new prevgroups grouplist to the struct cred, maybe
>> >> > struct group_info *locked_groups, and every time an unprivileged task creates
>> >> > a new user namespace, add all its current groups to this list?
>> >>
>> >> So, effectively, you would be allowed to drop permissions, but
>> >> locked_groups would still be checked for restrictions?
>> >>
>> >> That seems like it'd introduce a new level of complexity (a new facet of
>> >> permission) to manage. Not opposed, but it does seem more complex than
>> >> just opting out of using groups for negative permissions.
>
> Yeah, it would, but I basically hoped that we could catch most of this at
> e.g. generic_permission(), and/or we could introduce a helper which
> automatically adds a check for permission denied from locked_groups, so
> it shouldn't be too wide-spread.  If it does end up showing up all over
> the place, then that's a good reason not to do this.
>
>> > Is there any context other than regular UNIX DAC in which groups can
>> > act as negative permissions or is this literally just an issue for
>> > files with a more restrictive group mode than other mode?
>> 
>> Just that.
>> 
>> The ideas kicked around in the conversation were some variant of having
>> a sysctl that says "This system never uses groups for negative
>> permissions".
>> 
>> It was also suggested that if the sysctl was set the the permission
>> checks would be altered such that even if someone tried to set a
>> negative permission, the more liberal permissions of other would be used
>> instead.
>
> So then this would touch all the same code points which the
> locked_groups approach would have to touch?

No locked_groups would touch in_group_p and set_groups.  Especially what
set_groups means in that context.  It would have to handle what happens
when you start accumulating locked groups (because of multiple
namespaces).  How you dedup locked groups etc.

I was not able to convince myself that not being able to clear out
groups that a user has when they create a user namespace won't cause
other problems.  Especially as user namespaces had been in use for a
while at that point.

Not supporting negative groups would touch acl_permission and modify it
like:

 static int acl_permission_check(struct inode *inode, int mask)
 {
[irrelveant code snipped]
 	/* Only RWX matters for group/other mode bits */
 	mask &= 7;
 
 	/*
 	 * Are the group permissions different from
 	 * the other permissions in the bits we care
 	 * about? Need to check group ownership if so.
 	 */
 	if (mask & (mode ^ (mode >> 3))) {
-		if (in_group_p(inode->i_gid))
+		if (in_group_p(inode->i_gid) &&
+		    (!sysctl_force_positive_groups ||
+		    (mask & ~(mode >> 3)))
 			mode >>= 3;
 	}
 
 	/* Bits in 'mode' clear that we require? */
 	return (mask & ~mode) ? -EACCES : 0;
 }


I don't know that we need to do that.  But it would might be a good way
of flushing out the issues.


>> Given that creating /etc/subgid is effectively opting out of negative
>> permissions already have a sysctl that says that upfront feels like a
>> very clean solution.
>> 
>> Eric
>
> That feels like a cop-out to me.  If some young admin at Roxxon Corp decides
> she needs to run a container, so installs subuid package and sets that sysctl,
> how does she know whether or not some previous admin, who has since retired and
> did not keep good docs, set things up so that a negative acl is keeping nginx
> from reading some supersecret doc?
>
> Now personally I'm not a great believer in the negative acls so I think the
> above is a very unlikely scenario, but if we're going to worry about it, then
> we should worry about it :)

There is a different between guaranting we don't break existing setups
when a new feature is enabled, and supporting old very rare setups when
a new feature is enabled.


> "Click this button if noone has ever used feature X on this server"

My current thinking is that if we already don't honor negative groups
when /etc/subgid exists it would not hurt to make that more explicit.


From what we could tell at the time people that know negative groups are
honored much less systems that actually use negative groups are
exceedingly rare.

Eric

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
