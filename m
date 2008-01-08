From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Subject: Re: util-linux-ng: unprivileged mounts support
Date: Tue, 8 Jan 2008 15:47:18 +0000
Message-ID: <20080108154718.GH4222@implementation.uk.xensource.com>
References: <E1JCCyk-0002pY-AM@pomaz-ex.szeredi.hu> <200801081031.06826.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760266AbYAHPsS@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200801081031.06826.vapier@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, util-linux-ng@vger.kernel.org, akpm@linux-foundation.org, hch@infradead.org, serue@us.ibm.com, viro@ftp.linux.org.uk, ebiederm@xmission.com, kzak@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Mike Frysinger, le Tue 08 Jan 2008 10:31:04 -0500, a =E9crit :
> with all the non-linux changes that have gone in, does there need to =
be header=20
> checks here and then have mount.c key off of them ?  i'm thinking so =
=2E..

Sure!

Samuel
--
To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
