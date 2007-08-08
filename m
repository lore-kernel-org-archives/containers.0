From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 0/25] Sysfs cleanups & tagged directory support
Date: Wed, 08 Aug 2007 16:53:23 +0900
Message-ID: <46B97673.4060009@gmail.com>
References: <11860582832964-git-send-email-htejun@gmail.com>	<m1643rkqb6.fsf@ebiederm.dsl.xmission.com>	<20070808093815.0935a18e@gondolin.boeblingen.de.ibm.com> <m1bqdifowo.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752853AbXHHHyB@vger.kernel.org>
In-Reply-To: <m1bqdifowo.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>, Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Cornelia Huck <cornelia.huck@de.ibm.com> writes:
> 
>> My udev failed to create /dev/dasd* so it cannot mount root :( I'm
>> currently trying to find out what causes this, may take some time...
> 
> Oh weird.
> 
> No great surprise that something goofed up given how many
> patches were involved.  Still there shouldn't have been
> any user visible differences in the patchset.
> 
> If you can narrow down which patch caused the problem that would be
> great.
> 
> Otherwise I guess I will have to start looking at the code and
> trying to guess what might have triggered this.

JFYI, your patchset works fine on my x86-64 test machine.  Corenelia
tests on a s390 system which does rename/move stuff with its devices and
usually gets hit first if something is wrong.  I'll scream if I find
anything suspicious while reviewing.

Thanks.

-- 
tejun
