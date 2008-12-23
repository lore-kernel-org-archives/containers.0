From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC][PATCH 0/6][v3] Container-init signal semantics
Date: Tue, 23 Dec 2008 10:51:21 -0600
Message-ID: <20081223165121.GA18031@us.ibm.com>
References: <20081221005106.GA4912@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752875AbYLWQvf@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081221005106.GA4912@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev@linux.vnet.ibm.com):
> 
> Container-init must behave like global-init to processes within the
> container and hence it must be immune to unhandled fatal signals from
> within the container (i.e SIG_DFL signals that terminate the process).
> 
> But the same container-init must behave like a normal process to 
> processes in ancestor namespaces and so if it receives the same fatal
> signal from a process in ancestor namespace, the signal must be
> processed.
> 
> Implementing these semantics requires that send_signal() determine pid
> namespace of the sender but since signals can originate from workqueues/
> interrupt-handlers, determining pid namespace of sender may not always
> be possible or safe.

Tested-by: Serge Hallyn <serue@us.ibm.com>

Tested sending signals to a custom container-init.

Are you planning to address Oleg's comments with a new patch-set,
or with patches on top of this set?

thanks,
-serge
