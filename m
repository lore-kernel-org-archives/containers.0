From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Per-instance devpts
Date: Sun, 3 Aug 2008 18:54:33 +0100
Message-ID: <20080803185433.7cfedccb@lxorguk.ukuu.org.uk>
References: <20080412172933.GA19295@us.ibm.com>
	<1208027215.28187.17.camel@x61.ebiederm.org>
	<48935205.3090807@zytor.com>
	<20080803050800.GA4322@us.ibm.com>
	<20080803130439.743ff0ae@lxorguk.ukuu.org.uk>
	<20080803174646.GA20254@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758920AbYHCSMS@vger.kernel.org>
In-Reply-To: <20080803174646.GA20254@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: sukadev@us.ibm.com
Cc: "H. Peter Anvin" <hpa@zytor.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@osdl.org>, serue@us.ibm.com, matthltc@us.ibm.com, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Greg KH <greg@kroah.com>
List-Id: containers.vger.kernel.org

> If /dev/pts/1 is the controlling terminal and there are multiple mounts
> of devpts, when we open /dev/tty, kernel would somehow have to find the
> right instance of devpts.

current->tty - it is a direct internal reference.

Alan
