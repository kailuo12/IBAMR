#ifndef included_IBBeamForceGen
#define included_IBBeamForceGen

// Filename: IBBeamForceGen.h
// Last modified: <29.Mar.2007 16:16:51 griffith@box221.cims.nyu.edu>
// Created on 22 Mar 2007 by Boyce Griffith (griffith@box221.cims.nyu.edu)

/////////////////////////////// INCLUDES /////////////////////////////////////

// IBAMR INCLUDES
#include <ibamr/IBLagrangianForceStrategy.h>

// PETSc INCLUDES
#include <petscmat.h>

// C++ STDLIB INCLUDES
#include <vector>

/////////////////////////////// CLASS DEFINITION /////////////////////////////

namespace IBAMR
{
/*!
 * \brief Class IBBeamForceGen is a concrete IBLagrangianForceStrategy
 * that computes the force generated by a collection of linear or
 * beams.
 *
 * \see IBBeamForceSpec
 */
class IBBeamForceGen
    : public IBLagrangianForceStrategy
{
public:
    /*!
     * \brief Default constructor.
     */
    IBBeamForceGen(
        SAMRAI::tbox::Pointer<SAMRAI::tbox::Database> input_db=NULL);

    /*!
     * \brief Virtual destructor.
     */
    virtual ~IBBeamForceGen();

    /*!
     * \brief Setup the data needed to compute the beam forces on
     * the specified level of the patch hierarchy.
     */
    virtual void initializeLevelData(
        const SAMRAI::tbox::Pointer<SAMRAI::hier::PatchHierarchy<NDIM> > hierarchy,
        const int level_number,
        const double init_data_time,
        const bool initial_time,
        const LDataManager* const lag_manager);

    /*!
     * \brief Compute the beam forces generated by the Lagrangian
     * structure on the specified level of the patch hierarchy.
     *
     * \note Nodal forces computed by this method are \em added to the
     * force vector.
     */
    virtual void computeLagrangianForce(
        SAMRAI::tbox::Pointer<LNodeLevelData> F_data,
        SAMRAI::tbox::Pointer<LNodeLevelData> X_data,
        SAMRAI::tbox::Pointer<LNodeLevelData> U_data,
        const SAMRAI::tbox::Pointer<SAMRAI::hier::PatchHierarchy<NDIM> > hierarchy,
        const int level_number,
        const double data_time,
        const LDataManager* const lag_manager);

private:
    /*!
     * \brief Copy constructor.
     *
     * \note This constructor is not implemented and should not be
     * used.
     *
     * \param from The value to copy to this object.
     */
    IBBeamForceGen(
        const IBBeamForceGen& from);

    /*!
     * \brief Assignment operator.
     *
     * \note This operator is not implemented and should not be used.
     *
     * \param that The value to assign to this object.
     *
     * \return A reference to this object.
     */
    IBBeamForceGen& operator=(
        const IBBeamForceGen& that);

    /*!
     * \brief Read input values, indicated above, from given database.
     *
     * The database pointer may be null.
     */
    void getFromInput(
        SAMRAI::tbox::Pointer<SAMRAI::tbox::Database> db);

    /*!
     * \name Data maintained separately for each level of the patch
     * hierarchy.
     */
    //\{
    std::vector<Mat> d_D_next_mats, d_D_prev_mats;
    std::vector<std::vector<int> > d_petsc_mastr_node_idxs, d_petsc_next_node_idxs, d_petsc_prev_node_idxs;
    std::vector<std::vector<double> > d_bend_rigidities;
    std::vector<bool> d_is_initialized;
    //\}
};
}// namespace IBAMR

/////////////////////////////// INLINE ///////////////////////////////////////

//#include <ibamr/IBBeamForceGen.I>

//////////////////////////////////////////////////////////////////////////////

#endif //#ifndef included_IBBeamForceGen
