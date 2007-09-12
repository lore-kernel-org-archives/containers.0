From: Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
Subject: Re: [PATCH] Hookup group-scheduler with task container infrastructure
Date: Wed, 12 Sep 2007 17:40:42 +0530
Message-ID: <20070912121042.GI16222@linux.vnet.ibm.com>
References: <20070910171049.GA16048@linux.vnet.ibm.com> <Pine.LNX.4.64.0709101903220.5368@fbirervta.pbzchgretzou.qr> <20070910172334.GB19100@linux.vnet.ibm.com> <20070910102259.dc45a481.akpm@linux-foundation.org> <20070910174649.GA16222@linux.vnet.ibm.com> <b647ffbd0709101528i7440a0f9m9837065a43e4a720@mail.gmail.com> <20070911044145.GC16222@linux.vnet.ibm.com> <b647ffbd0709110253y7d9564c4j88aa134330e2a292@mail.gmail.com> <20070912114202.GA30385@linux.vnet.ibm.com>
Reply-To: vatsa@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S967292AbXILMAa@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070912114202.GA30385@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: menage@google.com, ckrm-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org, Jan Engelhardt <jengelh@computergmbh.de>, containers@lists.osdl.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org

On Wed, Sep 12, 2007 at 05:12:02PM +0530, Srivatsa Vaddagiri wrote:
> Yes. To emphasise this code doesn't support real-time tasks in a container, I 
> am returning -ENOTSUP when trying to move a rt-task into a container.

s/ENOTSUP/EINVAL

-- 
Regards,
vatsa
