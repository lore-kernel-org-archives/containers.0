From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 0/25] Sysfs cleanups & tagged directory support
Date: Wed, 8 Aug 2007 09:54:32 +0200
Message-ID: <20070808095432.4a520735@gondolin.boeblingen.de.ibm.com>
References: <11860582832964-git-send-email-htejun@gmail.com>
	<m1643rkqb6.fsf@ebiederm.dsl.xmission.com>
	<20070808093815.0935a18e@gondolin.boeblingen.de.ibm.com>
	<m1bqdifowo.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762562AbXHHHxm@vger.kernel.org>
In-Reply-To: <m1bqdifowo.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, stern@rowland.harvard.edu, Tejun Heo <htejun@gmail.com>, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

On Wed, 08 Aug 2007 01:47:51 -0600,
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Cornelia Huck <cornelia.huck@de.ibm.com> writes:
> 
> > My udev failed to create /dev/dasd* so it cannot mount root :( I'm
> > currently trying to find out what causes this, may take some time...
> 
> Oh weird.
> 
> No great surprise that something goofed up given how many
> patches were involved.  Still there shouldn't have been
> any user visible differences in the patchset.
> 
> If you can narrow down which patch caused the problem that would be
> great.

Got it: It's patch 6, the readdir simplification.

(The udev on that guest is ancient (063)...)
