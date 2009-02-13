From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 4/4] keys: make procfiles per-user-namespace
Date: Fri, 13 Feb 2009 11:03:10 +0000
Message-ID: <5296.1234522990@redhat.com>
References: <20090109225313.GB15599@us.ibm.com> <20090109225208.GA15252@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758228AbZBMLDy@vger.kernel.org>
In-Reply-To: <20090109225313.GB15599@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: dhowells@redhat.com, lkml <linux-kernel@vger.kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn <serue@us.ibm.com> wrote:

> Restrict the /proc/keys and /proc/key-users output to keys
> belonging to the same user namespace as the reading task.
> 
> We may want to make this more complicated - so that any
> keys in a user-namespace which is belongs to the reading
> task are also shown.  But let's see if anyone wants that
> first.

Hmmm...  I wonder if we can do better by making the file position indicate the
key ID rather than being a count of the number of keys read.  It might make
this cleaner.

David
