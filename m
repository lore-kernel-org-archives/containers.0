From: sukadev@us.ibm.com
Subject: Re: [PATCH 0/3] clone64() and unshare64() system calls
Date: Thu, 10 Apr 2008 11:26:16 -0700
Message-ID: <20080410182616.GF28477@us.ibm.com>
References: <20080409222611.GA28087@us.ibm.com> <47FD5899.2040206@zytor.com> <20080410010717.GA28477@us.ibm.com> <47FD6921.6090408@zytor.com> <20080410023818.GD28477@us.ibm.com> <6599ad830804091943j1f8a4500w5eda7774adfba69f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759050AbYDJS1y@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6599ad830804091943j1f8a4500w5eda7774adfba69f@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@osdl.org>, clg@fr.ibm.com, serue@us.ibm.com, "David C. Hansen" <haveblue@us.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Paul Menage [menage@google.com] wrote:
| On Wed, Apr 9, 2008 at 7:38 PM,  <sukadev@us.ibm.com> wrote:
| >
| >  But as Jon Corbet pointed out in the the thread above, it looked like
| >  adding a new system call has been the "traditional" way of solving this
| >  in Linux so far and there has been no consensus on a newer approach.
| >
| 
| I thought that the consensus was that adding a new system call was
| better than trying to force extensibility on to the existing
| non-extensible system call.

There were couple of objections to extensible system calls like
sys_indirect() and to Pavel's approach.

| 
| But if we are adding a new system call, why not make the new one
| extensible to reduce the need for yet another new call in the future?

hypothetically, can we make a variant of clone() extensible to the point
of requiring a copy_from_user() ?

| 
| Paul
