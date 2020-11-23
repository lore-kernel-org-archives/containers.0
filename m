Return-Path: <SRS0=EloL=E5=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 583F9C2D0E4
	for <containers@archiver.kernel.org>; Mon, 23 Nov 2020 15:47:36 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B8DD4208FE
	for <containers@archiver.kernel.org>; Mon, 23 Nov 2020 15:47:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8DD4208FE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 4A14B8707F;
	Mon, 23 Nov 2020 15:47:35 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id yQQNBJE21VjX; Mon, 23 Nov 2020 15:47:34 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id B305E87028;
	Mon, 23 Nov 2020 15:47:34 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A033BC0891;
	Mon, 23 Nov 2020 15:47:34 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 4B27CC0052
 for <containers@lists.linux-foundation.org>;
 Mon, 23 Nov 2020 15:47:33 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 3988B8672A
 for <containers@lists.linux-foundation.org>;
 Mon, 23 Nov 2020 15:47:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id tzccYl2E292c
 for <containers@lists.linux-foundation.org>;
 Mon, 23 Nov 2020 15:47:32 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com
 [66.111.4.230])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 9BDC386726
 for <containers@lists.linux-foundation.org>;
 Mon, 23 Nov 2020 15:47:32 +0000 (UTC)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
 by mailnew.nyi.internal (Postfix) with ESMTP id D00855803A4;
 Mon, 23 Nov 2020 10:47:30 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
 by compute6.internal (MEProxy); Mon, 23 Nov 2020 10:47:30 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm1; bh=YCozEjPGEAusuu5kWcPoz4VuSgu
 BS8YGOeXbic2f3Rk=; b=pvyJJQ7dtuKuZyz5d3i/Y2P3BtpwgiXvwkMU5BeT/T2
 WF7NIU3puTeGziHc3V8c4P08DDWx0C/mg8YCh+U9Sca9z/JBHq4wxcxz+bm/x/Js
 ill0yaXVsNoxFGfzUBheTBFxcrVd8m1grxm7s7iqfhMx/pqXZTmktPvPSGUH1K+i
 VvxsyMeiQnZ801Wg/2mHiLsPZGF/gI01gimS5m/ZBxf0fuByrLF38kRtIG8KpJoC
 GjM0bMurgM8uw9HPIxfjJfQMxd6piCxFrXhJwKKVnPi4S2MGSK9vrSe50wmN6ozJ
 wPMGgnj6yqYl5/R8VxfTmCS+UTwBxYo6D54TxCJcS8A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=YCozEj
 PGEAusuu5kWcPoz4VuSguBS8YGOeXbic2f3Rk=; b=WeTek+Xz2c2hE5akKms3c+
 JeQuMni5IamwAYJBT/m7URxRjdbl3G1N+579hB8TJU7hVr8i4qroe26PJ3If/+wN
 Qy/X8fRJQXhvKWoGWjNKkJOYeaW/AZ0EpTpZIyp6yvUY5A3Rrv+LpcWilbxoFfyJ
 OP2LRptG+oKP0efDk+2PvtUyoy9XYB07mY8m0aI7DiEIgovl7mAXAN3Bf0YNAFRl
 jxkRqX5pKm7uJ55WMJLJWPae4lZpqOCzd0ZA9zA5cLRvER2UcwplWM5qIoZCOWR5
 wc6xoAs15KiJGximzPI2SWI4DgpHPxy+EhzRGjAX7GrlMgOFuCnOTi8X3+CgTwPw
 ==
X-ME-Sender: <xms:kNm7X-6VybmnIE7HxBF78RbqSph39ZGAjm52Jziqp6YhvS6SutsV3g>
 <xme:kNm7X37G5hrBHr_ofSXlbfBd7NIArMQy5vyzjbdcfCZMiQhtsghJXDiLqbJDjXPbG
 4pkUDJOybMd7fnmfxg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedrudegiedgkedvucetufdoteggodetrfdotf
 fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
 uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
 cujfgurhepfffhvffukfhfgggtuggjsehttdertddttddvnecuhfhrohhmpefvhigthhho
 ucetnhguvghrshgvnhcuoehthigthhhosehthigthhhordhpihiiiigrqeenucggtffrrg
 htthgvrhhnpeegkeefjeegkedtjefgfeduleekueetjeeghffhuefgffefleehgeeifedv
 gfethfenucfkphepuddvkedruddtjedrvdeguddrudejgeenucevlhhushhtvghrufhiii
 gvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpehthigthhhosehthigthhhordhpihii
 iigr
X-ME-Proxy: <xmx:kNm7X9cPIAKRhCP04Kj8q43f_nFo2EYWIGVCCaxjvTW9N8SJ8w8jVQ>
 <xmx:kNm7X7JU-QaZeelrk4qvOdP93F1LE0ucN_vNnd5Copq4DsgabUHEbQ>
 <xmx:kNm7XyLAnKZzuImxS6me0molLz2ayvhe0zjr3tUiP9xn0aaEnjdKTw>
 <xmx:ktm7X-pza5kZuwtkUTGD6q3OiEh8E1SHpU53XCgKODHJj5cEjL4fZA>
Received: from cisco (unknown [128.107.241.174])
 by mail.messagingengine.com (Postfix) with ESMTPA id C041D3064ABE;
 Mon, 23 Nov 2020 10:47:21 -0500 (EST)
Date: Mon, 23 Nov 2020 10:47:19 -0500
From: Tycho Andersen <tycho@tycho.pizza>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: [PATCH v2 07/39] mount: attach mappings to mounts
Message-ID: <20201123154719.GD4025434@cisco>
References: <20201115103718.298186-1-christian.brauner@ubuntu.com>
 <20201115103718.298186-8-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201115103718.298186-8-christian.brauner@ubuntu.com>
Cc: Andy Lutomirski <luto@kernel.org>, Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 Christoph Hellwig <hch@infradead.org>,
 Casey Schaufler <casey@schaufler-ca.com>, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, Jann Horn <jannh@google.com>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Lennart Poettering <lennart@poettering.net>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 containers@lists.linux-foundation.org, linux-security-module@vger.kernel.org,
 linux-audit@redhat.com, "Eric W. Biederman" <ebiederm@xmission.com>,
 linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 Alban Crequy <alban@kinvolk.io>, linux-integrity@vger.kernel.org,
 Stephen Smalley <stephen.smalley.work@gmail.com>, Todd Kjos <tkjos@google.com>
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

On Sun, Nov 15, 2020 at 11:36:46AM +0100, Christian Brauner wrote:
> +static inline struct user_namespace *mnt_user_ns(const struct vfsmount *mnt)
> +{
> +	return mnt->mnt_user_ns;
> +}

I think you might want a READ_ONCE() here. Right now it seems ok, since the
mnt_user_ns can't change, but if we ever allow it to change (and I see you have
a idmapped_mounts_wip_v2_allow_to_change_idmapping branch on your public tree
:D), the pattern of,

        user_ns = mnt_user_ns(path->mnt);
        if (mnt_idmapped(path->mnt)) {
                uid = kuid_from_mnt(user_ns, uid);
                gid = kgid_from_mnt(user_ns, gid);
        }

could race.

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
