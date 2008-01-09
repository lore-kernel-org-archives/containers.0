From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [patch 5/9] unprivileged mounts: allow unprivileged bind mounts
Date: Wed, 09 Jan 2008 14:32:00 +0100
Message-ID: <E1JCb2G-0005pD-FY@pomaz-ex.szeredi.hu>
References: <20080108113502.184459371@szeredi.hu> <20080108113626.895583537@szeredi.hu> <1199815958.9834.58.camel@localhost> <E1JCJoQ-0003g9-Nk@pomaz-ex.szeredi.hu> <Pine.LNX.4.64.0801091340270.29244@fbirervta.pbzchgretzou.qr> <20080109132610.GJ3926@petra.dvoda.cz>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-reply-to: <20080109132610.GJ3926@petra.dvoda.cz> (message from Karel Zak on
	Wed, 9 Jan 2008 14:26:10 +0100)
Sender: linux-fsdevel-owner@vger.kernel.org
To: kzak@redhat.com
Cc: jengelh@computergmbh.de, miklos@szeredi.hu, haveblue@us.ibm.com, akpm@linux-foundation.org, hch@infradead.org, serue@us.ibm.com, viro@ftp.linux.org.uk, ebiederm@xmission.com, linux-fsdevel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

>     case EMFILE:
>       error ("mount table full"); break;

OK, we could go with EMFILE, but the message should be changed to
something like "maximum unprivileged mount count exceeded".

Miklos
