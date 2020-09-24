Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67556C4363D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 17:09:38 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C00B0238A1
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 17:09:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hWsBnfua"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C00B0238A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 4835B87507;
	Thu, 24 Sep 2020 17:09:37 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id AJHsbtGyNq44; Thu, 24 Sep 2020 17:09:36 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 9975D874F9;
	Thu, 24 Sep 2020 17:09:36 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 70DB9C0859;
	Thu, 24 Sep 2020 17:09:36 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A5D7EC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 17:09:35 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 93C078697E
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 17:09:35 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Uf5VB8KtVWbI
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 17:09:34 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com
 [209.85.160.196])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 38ED88542A
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 17:09:34 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id a4so3606948qth.0
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 10:09:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=XEqUeG/tc6d67wDLsNkihR1RVL8pCmrN8K2kkC/wiEQ=;
 b=hWsBnfuapi1W5g5F3IorK2xtU9ghaHTm6zMbZs6LoQ+n1q9fmfjTZwwo+gUd4tvEfk
 TnJTupnvK0fudD+fizRlbyqQdjM7Czo6W3nDJjFDFkHijAkxMGCnnPehNqzB2MezIugA
 SmK7JPy0zcY1MPy5bim5dB5xDa+4UMh9juhHmWqr9wOP7/cAQX1jUPHeD1rtMOYjoRyF
 yxmmrDLSr1ksPEF4WjGm74eBDWXjZXaHcvsf5yrXss0tNJUOX0iEtxhfgbzhr83aEOVD
 3CMP5UXxbB7O2ywaGzupnY8WX5NUWGI73dX1Uk3d6sx8eK+QkAcLahe/yN13SQcaH5pK
 Y+7w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=XEqUeG/tc6d67wDLsNkihR1RVL8pCmrN8K2kkC/wiEQ=;
 b=tnImH+ML3KNP7zZ69EDe7iA6oWQIDs9K84tn+hJw6MinBzXWVicmHtiUag/qSBC8G/
 4m+LqIaoWl1FXdCYmBtuMZT//xfU41kNK2ft44W8MKsFQdYn69ObhDlmeoX8cSYnRvIx
 rbHWZwZQ6XweCU+wjCY93feJl2VXL123t/1ehX96EEemhJ5S8LEA9/qWqjQfkfzgGM0T
 y7XOwCCyfUlrLNYo+/mox6OWgaFixfh50zRiUbWgIQxSuVv8pcfIQah3IuiDwH3O7HpR
 VsPj5WOvgpnBv5YkkIufd7pf9p+rUlCBSgzyPlsJnyx3OD4C9S9YsJedcau+E8Mn6MZZ
 X51w==
X-Gm-Message-State: AOAM532+k/i8vrVaUPfn3jrnweTcpIQwlbx5AQ7g4Z7CvbvyhCx0Ecm9
 ALGmCh+9C+ZVJBu/C8KY8hHlQRsnSN7wNhAi4JQ=
X-Google-Smtp-Source: ABdhPJz9uhVM5+sQ5Ak+W/FfWWOMx4ljYEY+wzsvg+8H0drWewPR2JxFX3qn6irY5utbRGyS9nvMurHqdrd55mrprKo=
X-Received: by 2002:aed:2703:: with SMTP id n3mr48650qtd.235.1600967373087;
 Thu, 24 Sep 2020 10:09:33 -0700 (PDT)
MIME-Version: 1.0
References: <87zh6eiyv7.fsf@x220.int.ebiederm.org>
 <20200901060631.GA5193@mail.hallyn.com>
 <871rjleefo.fsf@x220.int.ebiederm.org>
In-Reply-To: <871rjleefo.fsf@x220.int.ebiederm.org>
From: Alban Crequy <alban.crequy@gmail.com>
Date: Thu, 24 Sep 2020 19:09:21 +0200
Message-ID: <CAMXgnP4WLJt+k_R8E9cbfCatV5Sevqh=uYPK9VRB0SYTY=QmtA@mail.gmail.com>
Subject: Re: Use cases for multiple uid mapping?
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linux Containers <containers@lists.linux-foundation.org>
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

On Tue, 1 Sep 2020 at 16:53, Eric W. Biederman <ebiederm@xmission.com> wrote:
>
> "Serge E. Hallyn" <serge@hallyn.com> writes:
>
> > On Fri, Aug 28, 2020 at 10:17:16AM -0500, Eric W. Biederman wrote:
> >>
> >> We had a discussion in the hackroom at LPC talking about use cases for
> >> a shiftfs style setup where there are different mappings of uids to
> >> disk.
> >>
> >> In the discussion we had a couple of ideas of kernel developments
> >> we should look at that address some of these.
> >>
> >> - Fix rlimits in user namespaces (This potentially allows multiple
> >>   containers to run with the same userids simplifying the mapping
> >>   problem).
> >>
> >> - Look at extending kuid_t to 64bits and using the highbits to
> >>   implement uids that are private to user namespaces and don't
> >>   map out.
> >>
> >> - Look at ways for allowing setgroups unprivileged.
> >>
> >>
> >> Together this has the potential that the existing uid & gid mappings
> >> will be able to function the same as the proposed fusid mappings. Fingers crossed.
> >>
> >>
> >> I had some problems with audio and a lot of people were talking
> >> quickly.  So I did not manage to capture everyone's use cases.   And I
> >> definitely was not able to see how everyone's use cases interacted with
> >> the changes we are looking at.
> >>
> >> I know for certain I missed Serge's usecase (apologies).
> >>
> >> Can people follow up to this and report their use cases?
> >
> > Sorry - I'll do so later this week.
>
> Thank you.
>
> I know we have the OCI use case of overlayfs and sharing storage
> between containers.

Is there a description of this use case, and ideas of possible solutions?

There was a use case that was brought to a recent Kubernetes sig-node
meeting, but I am not sure it is the same one, so I'll describe this
one.

We're working to enable user namespaces in Kubernetes with two possible setups:
1. Each Kubernetes pod has its own userns but with the same user id
mapping (to make it easy to manage shared volumes)
2. Each Kubernetes pod has its own userns with non-overlapping user id
mapping (providing additional isolation between pods)

Pods could be executed with a Kubernetes sidecar such as Envoy,
meaning that if there are 'n' pods running on a node, there will be
'n' containers running the Envoy container image. In the second setup,
each Envoy container will have a different user id mapping.

The Envoy container image will be snapshotted in as many copies, and
each copy will be chown'ed appropriately for each non-overlapping user
id mapping. Each copy will then be used as the lowerdir for the
overlayfs rootfs of the container.

This results in a waste of disk space. Without user namespaces, we
don't have this problem, since the same directory can be used as
lowerdir for each container's overlayfs rootfs.

This is not specific to sidecars, but they exacerbate the problem.

I was not present in the Plumbers discussions, so I don't know if
possible solutions were discussed. For example: could overlayfs get a
mount option to specify an id mapping to apply on the lowerdir? In the
case of containerd + runc, the mount option would probably need to be
an id mapping rather than a reference to an existing user namespace,
because the overlayfs mount is set up by containerd before runc is
executed, so before the user namespace is unshared.

Alban

> I know we have the lxc case of not wanting to be strangled by ulimits.
> So not using the same uid between containers even when it is logically
> the same users.
>
> I know the brainstorming was going a lot of different directions and I
> piped up and said that we should probably focus on handling the stranger
> cases with fuse mounts, and the other capabilities we have now.
>
> It really will be valuable to understand the other cases so we don't
> code ourselves into a corner that only works for the most vocal of the
> developers.
>
> Eric
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
