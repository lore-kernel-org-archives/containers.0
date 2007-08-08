From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 0/25] Sysfs cleanups & tagged directory support
Date: Wed, 8 Aug 2007 17:15:00 +0200
Message-ID: <20070808171500.5df073de@gondolin.boeblingen.de.ibm.com>
References: <11860582832964-git-send-email-htejun@gmail.com>
	<m1643rkqb6.fsf@ebiederm.dsl.xmission.com>
	<20070808093815.0935a18e@gondolin.boeblingen.de.ibm.com>
	<m1bqdifowo.fsf@ebiederm.dsl.xmission.com>
	<20070808095432.4a520735@gondolin.boeblingen.de.ibm.com>
	<m17io6foh8.fsf@ebiederm.dsl.xmission.com>
	<20070808103759.0850383c@gondolin.boeblingen.de.ibm.com>
	<20070808161631.1ccf27fd@gondolin.boeblingen.de.ibm.com>
	<46B9D4B8.4050201@gmail.com>
	<20070808165027.29af40b5@gondolin.boeblingen.de.ibm.com>
	<46B9D961.4000902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964812AbXHHPOa@vger.kernel.org>
In-Reply-To: <46B9D961.4000902@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <htejun@gmail.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

On Wed, 08 Aug 2007 23:55:29 +0900,
Tejun Heo <htejun@gmail.com> wrote:

> Yeah, you seem to have 32bit off_t.  UINT_MAX overflows, so...

<checks> Yes, that was an 31 bit guest. (Good thing I tried it there, I
usually use 64 bit guests...)
