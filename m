From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [patch -mm 0/4] mqueue namespace
Date: Thu, 29 Nov 2007 10:52:28 +0100
Message-ID: <474E8BDC.4080403@fr.ibm.com>
References: <20071128163728.177495768@fr.ibm.com>> <474DA549.6060408@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761505AbXK2Jwo@vger.kernel.org>
In-Reply-To: <474DA549.6060408@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> Cedric Le Goater wrote:
>> Hello ! 
>>
>> Here's a small patchset introducing a new namespace for POSIX
>> message queues. 
>>
>> Nothing really complex a part from the mqueue filesystem which 
>> needed some special care
> 
> Hm... Why did you decided to make it separately from the
> IPC namespace?

Mostly because it has its own configuration option and filesystem
which requires to clone also the mnt namespace.  

but yes they could probably be merged. Let's see what the others 
have to say about it.

C.
