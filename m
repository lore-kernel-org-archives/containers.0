From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] Hookup group-scheduler with task container infrastructure
Date: Tue, 11 Sep 2007 08:44:47 -0700
Message-ID: <6599ad830709110844q143b55fi95a4398261075f9d@mail.gmail.com>
References: <20070910171049.GA16048@linux.vnet.ibm.com>
	 <Pine.LNX.4.64.0709101903220.5368@fbirervta.pbzchgretzou.qr>
	 <20070910172334.GB19100@linux.vnet.ibm.com>
	 <20070910102259.dc45a481.akpm@linux-foundation.org>
	 <20070910174649.GA16222@linux.vnet.ibm.com>
	 <b647ffbd0709101537l9af4dc8x743b25c96e0f5235@mail.gmail.com>
	 <6599ad830709101545s66fd338dob6932407db4e1002@mail.gmail.com>
	 <46E641C1.8000808@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761166AbXIKPo7@vger.kernel.org>
In-Reply-To: <46E641C1.8000808@fr.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Cedric Le Goater <clg@fr.ibm.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>, vatsa@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, ckrm-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org, containers@lists.osdl.org, Jan Engelhardt <jengelh@computergmbh.de>, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org

On 9/11/07, Cedric Le Goater <clg@fr.ibm.com> wrote:
> >
> > And "group" is more or less implied by the fact that it's in the
> > containers/control groups filesystem.
>
> "control groups" is the name of your framework. right ?

That's the main contender for the new name, to replace "task
containers" since there were enough objections. (Renamed patches
coming out today, I hope).

Paul
