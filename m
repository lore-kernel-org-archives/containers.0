From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 4/4] keys: make procfiles per-user-namespace
Date: Mon, 23 Feb 2009 14:40:41 -0600
Message-ID: <20090223204041.GA31626@us.ibm.com>
References: <20090109225313.GB15599@us.ibm.com> <20090109225208.GA15252@us.ibm.com> <5296.1234522990@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754425AbZBWUlV@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5296.1234522990@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Quoting David Howells (dhowells@redhat.com):
> Serge E. Hallyn <serue@us.ibm.com> wrote:
> 
> > Restrict the /proc/keys and /proc/key-users output to keys
> > belonging to the same user namespace as the reading task.
> > 
> > We may want to make this more complicated - so that any
> > keys in a user-namespace which is belongs to the reading
> > task are also shown.  But let's see if anyone wants that
> > first.
> 
> Hmmm...  I wonder if we can do better by making the file position indicate the
> key ID rather than being a count of the number of keys read.  It might make
> this cleaner.

file position?  as in the result of lseek(fd, 0, SEEK_CUR)?

I don't understand what you're suggesting.

-serge
