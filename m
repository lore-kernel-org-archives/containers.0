From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 4/4] keys: make procfiles per-user-namespace
Date: Wed, 25 Feb 2009 23:53:22 +0000
Message-ID: <7386.1235606002@redhat.com>
References: <20090225210336.GA20086@us.ibm.com> <20090223204041.GA31626@us.ibm.com> <20090109225313.GB15599@us.ibm.com> <20090109225208.GA15252@us.ibm.com> <5296.1234522990@redhat.com> <16728.1235565664@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759827AbZBYXxl@vger.kernel.org>
In-Reply-To: <20090225210336.GA20086@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: dhowells@redhat.com, lkml <linux-kernel@vger.kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn <serue@us.ibm.com> wrote:

> So you want users to be able to mmap the file and lseek to a particular
> spot?

mmap?  *blink*

> Meanwhile, do you have any objections to these 4 patches?  :)

Not really.  You can add my Acked-by.  It's just that mapping fpos to keyid
might simplify the code.

David
