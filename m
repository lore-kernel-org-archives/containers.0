From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 03/33] task containersv11 add tasks file interface
Date: Wed, 3 Oct 2007 19:53:03 -0700
Message-ID: <6599ad830710031953o11265ff9kc0dc2bbd6b3b4793@mail.gmail.com>
References: <20070917210307.116234000@menage.corp.google.com>
	 <20070917210426.579524000@menage.corp.google.com>
	 <20071003010923.c606c176.pj@sgi.com>
	 <6599ad830710030816m32321b54gbc79c24d0a39941b@mail.gmail.com>
	 <20071003194652.873b0bcf.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756852AbXJDCx3@vger.kernel.org>
In-Reply-To: <20071003194652.873b0bcf.pj@sgi.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Jackson <pj@sgi.com>
Cc: akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, serue@us.ibm.com, clg@fr.ibm.com, ebiederm@xmission.com, xemul@openvz.org, rientjes@google.com, svaidy@linux.vnet.ibm.com, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 10/3/07, Paul Jackson <pj@sgi.com> wrote:
>
> I can't say for sure, but I suspect that if cgroups had always
> been cgroups (short for control groups), then these local 'cont'
> variables would have a different name.

Oh, absolutely. I just refrained from changing them in the rename
since the name was sort of still relevant and it made the change
simpler.

Paul
