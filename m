From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 0/3] clone64() and unshare64() system calls
Date: Wed, 9 Apr 2008 19:43:30 -0700
Message-ID: <6599ad830804091943j1f8a4500w5eda7774adfba69f@mail.gmail.com>
References: <20080409222611.GA28087@us.ibm.com> <47FD5899.2040206@zytor.com>
	 <20080410010717.GA28477@us.ibm.com> <47FD6921.6090408@zytor.com>
	 <20080410023818.GD28477@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756364AbYDJCnv@vger.kernel.org>
In-Reply-To: <20080410023818.GD28477@us.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: sukadev@us.ibm.com
Cc: "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@osdl.org>, clg@fr.ibm.com, serue@us.ibm.com, "David C. Hansen" <haveblue@us.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Wed, Apr 9, 2008 at 7:38 PM,  <sukadev@us.ibm.com> wrote:
>
>  But as Jon Corbet pointed out in the the thread above, it looked like
>  adding a new system call has been the "traditional" way of solving this
>  in Linux so far and there has been no consensus on a newer approach.
>

I thought that the consensus was that adding a new system call was
better than trying to force extensibility on to the existing
non-extensible system call.

But if we are adding a new system call, why not make the new one
extensible to reduce the need for yet another new call in the future?

Paul
