From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 0/25] Sysfs cleanups & tagged directory support
Date: Thu, 09 Aug 2007 00:13:37 +0900
Message-ID: <46B9DDA1.1080704@gmail.com>
References: <11860582832964-git-send-email-htejun@gmail.com>	<m1643rkqb6.fsf@ebiederm.dsl.xmission.com>	<20070808093815.0935a18e@gondolin.boeblingen.de.ibm.com>	<m1bqdifowo.fsf@ebiederm.dsl.xmission.com>	<20070808095432.4a520735@gondolin.boeblingen.de.ibm.com>	<m17io6foh8.fsf@ebiederm.dsl.xmission.com>	<20070808103759.0850383c@gondolin.boeblingen.de.ibm.com>	<20070808161631.1ccf27fd@gondolin.boeblingen.de.ibm.com>	<46B9D4B8.4050201@gmail.com>	<20070808165027.29af40b5@gondolin.boeblingen.de.ibm.com>	<46B9D961.4000902@gmail.com> <m1r6medpxl.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934628AbXHHPOE@vger.kernel.org>
In-Reply-To: <m1r6medpxl.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>, Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Tejun Heo <htejun@gmail.com> writes:
> 
>> Cornelia Huck wrote:
>>> On Wed, 08 Aug 2007 23:35:36 +0900,
>>> Tejun Heo <htejun@gmail.com> wrote:
>>>
>>>> Does the attached patch happen to fix the problem?
>>> Indeed it does; thanks!
>> Yeah, you seem to have 32bit off_t.  UINT_MAX overflows, so...
> 
> Weird.  And we have it opening the directory O_LARGEFILE.
> 
> I have no problems with the fix though.

It's probably because of struct dirent definition used by readdir().  It
may differ depending on archs and glibc version but IIRC the backend
implementation of all directory listing functions in glibc were the
same.  It opens with O_LARGEFILE and use getdents64 to get full info
then clip it to whatever limit the called API imposes.

-- 
tejun
