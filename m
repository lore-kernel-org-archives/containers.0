From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 4/4] keys: make procfiles per-user-namespace
Date: Wed, 25 Feb 2009 12:41:04 +0000
Message-ID: <16728.1235565664@redhat.com>
References: <20090223204041.GA31626@us.ibm.com> <20090109225313.GB15599@us.ibm.com> <20090109225208.GA15252@us.ibm.com> <5296.1234522990@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754383AbZBYMlV@vger.kernel.org>
In-Reply-To: <20090223204041.GA31626@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: dhowells@redhat.com, lkml <linux-kernel@vger.kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn <serue@us.ibm.com> wrote:

> > Hmmm...  I wonder if we can do better by making the file position indicate
> > the key ID rather than being a count of the number of keys read.  It might
> > make this cleaner.
> 
> file position?  as in the result of lseek(fd, 0, SEEK_CUR)?
> 
> I don't understand what you're suggesting.

Currently the file position on /proc/keys indicates the number of keys that
have been read.  It is incremented by 1 for each key read, irrespective of the
length of the line that was read for that key.

We could, instead, map file positions to key IDs, and skip any file positions
that don't actually map to an extant key.

David
