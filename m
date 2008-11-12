From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: Signals to cinit
Date: Wed, 12 Nov 2008 10:49:15 -0600
Message-ID: <20081112164915.GB14572@us.ibm.com>
References: <20081101180505.GA24268@us.ibm.com> <20081110173839.GA11121@redhat.com> <20081110193228.GA15519@redhat.com> <20081110232735.GA20891@us.ibm.com> <20081112145226.GA13269@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753800AbYKLQuB@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081112145226.GA13269@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: sukadev@linux.vnet.ibm.com, "Eric W. Biederman" <ebiederm@xmission.com>, Pavel Emelyanov <xemul@openvz.org>, daniel@hozac.com, Nadia Derbey <Nadia.Derbey@bull.net>, clg@fr.ibm.com, Containers <containers@lists.osdl.org>, sukadev@us.ibm.com, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Oleg Nesterov (oleg@redhat.com):
> > | Perhaps we can start with something like the patch below. Not that I like
> > | it very much though. We should really place this code under
> > | CONFIG_I_DO_CARE_ABOUT_NAMESPACES ;)
> >
> > CONFIG_PID_NS ?
> 
> Ah yes, we have it ;)

Except I believe all distros at this point enable CONFIG_PID_NS, so
I'm not sure it's the right thing to use.

-serge
