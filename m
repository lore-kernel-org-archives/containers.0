From: Bryan Donlan <bdonlan@gmail.com>
Subject: Re: [PATCH 0/7][v7] Container-init signal semantics
Date: Tue, 20 Jan 2009 23:39:27 -0500
Message-ID: <3e8340490901202039r1ac7e0te5372690dfe81089@mail.gmail.com>
References: <20090117202638.GA11825@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763575AbZAUEjl@vger.kernel.org>
In-Reply-To: <20090117202638.GA11825@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Sat, Jan 17, 2009 at 3:26 PM, Sukadev Bhattiprolu
<sukadev@linux.vnet.ibm.com> wrote:
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
>
> This patchset implements the design/simplified semantics suggested by
> Oleg Nesterov.  The simplified semantics for container-init are:
>
>        - container-init must never be terminated by a signal from a
>          descendant process.
>
>        - container-init must never be immune to SIGKILL from an ancestor
>          namespace (so a process in parent namespace must always be able
>          to terminate a descendant container).
>
>        - container-init may be immune to unhandled fatal signals (like
>          SIGUSR1) even if they are from ancestor namespace (SIGKILL is
>          the only reliable signal from ancestor namespace).

SIGSTOP is normally uncatchable; I note that patch 4 states that
SIGSTOP is allowed through to container-init, but given this summary
is SIGSTOP still reliable when sent to a container-init from an
ancestor namespace?
